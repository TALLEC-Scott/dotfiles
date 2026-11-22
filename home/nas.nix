{ config, pkgs, ... }:
let
  # "login\npassword" for the Freebox FTP server, from sops
  auth = config.sops.secrets.nas_ftp_auth.path;
  host = "mafreebox.freebox.fr"; # routed through the tunnel by vpn-nas
  # Top folder on the NAS (the Freebox partition name)
  nasRoot = "NAS Freebox";
  kpDir = "${nasRoot}/0-documents-importants/KeePassXC";

  # rclone remote "nas:" from env (login from sops, never on the command line)
  rcloneEnv = ''
    export RCLONE_CONFIG_NAS_TYPE=ftp RCLONE_CONFIG_NAS_HOST=${host}
    RCLONE_CONFIG_NAS_USER=$(sed -n 1p "${auth}"); export RCLONE_CONFIG_NAS_USER
    RCLONE_CONFIG_NAS_PASS=$(sed -n 2p "${auth}" | ${pkgs.rclone}/bin/rclone obscure -); export RCLONE_CONFIG_NAS_PASS
  '';

  kpdb = "${config.xdg.dataHome}/keepassxc/Passwords.kdbx";
  rc = "${pkgs.rclone}/bin/rclone -q --ftp-concurrency 2 --low-level-retries 3";

  # Shared part of kp-sync / kp-merge
  kpCommon = ''
    set -euo pipefail
    db="''${KPDB:-${kpdb}}"
    state="''${XDG_STATE_HOME:-$HOME/.local/state}/kp-sync.sha256"   # hash of last synced version
    remote="nas:${kpDir}/Passwords.kdbx"
    sha() { sha256sum < "$1" | cut -d' ' -f1; }
    reachable() { timeout 3 bash -c '</dev/tcp/${host}/21' 2>/dev/null; }
    tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
    ${rcloneEnv}
    fetch() { ${rc} copyto "$remote" "$tmp/nas.kdbx" 2>/dev/null || true; }
    upload() {
      ${rc} copyto "$db" "$remote"
      ${rc} copyto "$db" "nas:${kpDir}/Passwords-$(date +%F).kdbx"
      fetch; [ "$(sha "$tmp/nas.kdbx")" = "$(sha "$db")" ] || { echo "upload check failed" >&2; exit 1; }
    }
    record() { mkdir -p "$(dirname "$state")"; sha "$db" > "$state"; }
  '';

  # Safe two-way sync (timer): fast-forward whichever side changed; never overwrite both-changed.
  kp-sync = pkgs.writeShellScriptBin "kp-sync" ''
    ${kpCommon}
    [ -r "$db" ] || { echo "no database at $db (new machine? run kp-merge)" >&2; exit 1; }
    reachable || { echo "NAS not reachable (vpn-nas up?); will retry"; exit 0; }
    fetch
    last=$(cat "$state" 2>/dev/null || true)
    l=$(sha "$db")
    if [ ! -s "$tmp/nas.kdbx" ]; then upload; record; echo "uploaded (no copy on NAS yet)"; exit 0; fi
    r=$(sha "$tmp/nas.kdbx")
    if [ "$l" = "$r" ]; then record; echo "in sync"
    elif [ "$r" = "$last" ]; then upload; record; echo "uploaded local changes"
    elif [ "$l" = "$last" ]; then cp "$tmp/nas.kdbx" "$db"; chmod 600 "$db"; record; echo "downloaded NAS changes"
    else
      echo "both copies changed: run kp-merge" >&2
      ${pkgs.libnotify}/bin/notify-send "KeePassXC" "Both copies changed: run kp-merge" 2>/dev/null || true
      exit 1
    fi
  '';

  # Two-way merge (interactive, asks the master password once): NAS entries -> local, then upload.
  kp-merge = pkgs.writeShellScriptBin "kp-merge" ''
    ${kpCommon}
    reachable || { echo "NAS not reachable: vpn-nas up" >&2; exit 1; }
    fetch
    if [ ! -e "$db" ]; then   # new machine: take the NAS copy
      [ -s "$tmp/nas.kdbx" ] || { echo "no database locally or on the NAS" >&2; exit 1; }
      mkdir -p "$(dirname "$db")"; chmod 700 "$(dirname "$db")"
      cp "$tmp/nas.kdbx" "$db"; chmod 600 "$db"; record; echo "downloaded from NAS to $db"; exit 0
    fi
    if [ -s "$tmp/nas.kdbx" ] && [ "$(sha "$tmp/nas.kdbx")" != "$(sha "$db")" ]; then
      cp "$db" "$db.bak-$(date +%F-%H%M%S)"
      ${pkgs.keepassxc}/bin/keepassxc-cli merge --same-credentials "$db" "$tmp/nas.kdbx"
    fi
    upload; record; echo "merged and synced"
  '';
  nas = pkgs.writeShellScriptBin "nas" ''
    # Mount the Freebox NAS (FTP) at ~/nas with rclone (FUSE, no sudo).
    #   nas mount | umount | status | log
    set -euo pipefail
    mnt="$HOME/nas"
    log="''${XDG_CACHE_HOME:-$HOME/.cache}/nas-rclone.log"
    rclone=${pkgs.rclone}/bin/rclone

    case "''${1:-status}" in
      mount)
        if mountpoint -q "$mnt"; then echo "already mounted at $mnt"; exit 0; fi
        [ -r "${auth}" ] || { echo "NAS login not decrypted (${auth}); run hms" >&2; exit 1; }
        timeout 3 bash -c '</dev/tcp/${host}/21' 2>/dev/null \
          || { echo "NAS not reachable at ${host}; connect first: vpn-nas up" >&2; exit 1; }
        ${rcloneEnv}
        mkdir -p "$mnt" "$(dirname "$log")"
        # Freebox FTP allows few connections per user: cap them, reuse idle ones,
        # and cache listings so `ls` doesn't reopen connections every time.
        $rclone mount nas: "$mnt" --daemon --vfs-cache-mode writes \
          --ftp-concurrency 3 --checkers 2 --transfers 2 \
          --ftp-idle-timeout 5m --dir-cache-time 1h --attr-timeout 1m \
          --low-level-retries 3 \
          --log-file "$log" --log-level INFO
        for _ in $(seq 1 10); do mountpoint -q "$mnt" && break; sleep 1; done
        if mountpoint -q "$mnt" && ls "$mnt" >/dev/null 2>&1; then echo "mounted at $mnt"
        else echo "mount failed; see: nas log" >&2; fusermount3 -uz "$mnt" 2>/dev/null || true; exit 1; fi
        ;;
      umount|unmount)
        if mountpoint -q "$mnt"; then fusermount3 -u "$mnt" && echo "unmounted"; else echo "not mounted"; fi
        ;;
      status)
        if mountpoint -q "$mnt"; then echo "mounted at $mnt"; else echo "not mounted"; fi
        ;;
      log) tail -n "''${2:-30}" "$log" ;;
      *) echo "usage: nas mount|umount|status|log [lines]" >&2; exit 2 ;;
    esac
  '';
in
{
  sops.secrets.nas_ftp_auth = { };
  home.packages = [ nas kp-sync kp-merge pkgs.rclone ];

  # Sync the KeePassXC database with the NAS (when reachable)
  systemd.user.services.kp-sync = {
    Unit.Description = "Two-way sync of the KeePassXC database with the NAS";
    Service = {
      Type = "oneshot";
      ExecStart = "${kp-sync}/bin/kp-sync";
    };
  };
  # Local edits: sync as soon as KeePassXC saves the file (inotify; works on the WSL disk)
  systemd.user.paths.kp-sync = {
    Unit.Description = "Sync KeePassXC database when it changes";
    Path.PathChanged = kpdb;
    Install.WantedBy = [ "paths.target" ];
  };
  # NAS-side edits and retries after the VPN was down
  systemd.user.timers.kp-sync = {
    Unit.Description = "Sync KeePassXC database with the NAS hourly";
    Timer = { OnBootSec = "2min"; OnUnitActiveSec = "1h"; Persistent = true; };
    Install.WantedBy = [ "timers.target" ];
  };
}
