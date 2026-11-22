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

  # One-way backup of the KeePassXC database to the NAS, when it changed and the NAS is reachable
  kp-sync = pkgs.writeShellScriptBin "kp-sync" ''
    set -euo pipefail
    # rclone skips symlinks: resolve ~/Passwords.kdbx -> the Windows file
    src=$(readlink -f "''${KPDB:-$HOME/Passwords.kdbx}")
    state="''${XDG_STATE_HOME:-$HOME/.local/state}/kp-sync.sha256"
    [ -r "$src" ] || { echo "no database at $src" >&2; exit 1; }
    sum=$(sha256sum < "$src" | cut -d' ' -f1)
    if [ "''${1:-}" != "--force" ] && [ "$(cat "$state" 2>/dev/null)" = "$sum" ]; then
      echo "unchanged"; exit 0
    fi
    if ! timeout 3 bash -c '</dev/tcp/${host}/21' 2>/dev/null; then
      echo "NAS not reachable (vpn-nas up?); will retry"; exit 0
    fi
    [ -r "${auth}" ] || { echo "NAS login not decrypted; run hms" >&2; exit 1; }
    ${rcloneEnv}
    rc="${pkgs.rclone}/bin/rclone -q --ftp-concurrency 2 --low-level-retries 3"
    $rc copyto "$src" "nas:${kpDir}/Passwords.kdbx"
    $rc copyto "$src" "nas:${kpDir}/Passwords-$(date +%F).kdbx"
    size=$($rc size --json "nas:${kpDir}/Passwords.kdbx" | ${pkgs.jq}/bin/jq .bytes)
    [ "$size" = "$(stat -Lc %s "$src")" ] || { echo "size mismatch after upload" >&2; exit 1; }
    mkdir -p "$(dirname "$state")"; echo "$sum" > "$state"
    echo "backed up to NAS: ${kpDir}"
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
  home.packages = [ nas kp-sync pkgs.rclone ];

  # Back up the KeePassXC database to the NAS every 15 min (only if changed + reachable)
  systemd.user.services.kp-sync = {
    Unit.Description = "Back up KeePassXC database to the NAS";
    Service = {
      Type = "oneshot";
      ExecStart = "${kp-sync}/bin/kp-sync";
    };
  };
  systemd.user.timers.kp-sync = {
    Unit.Description = "Back up KeePassXC database to the NAS every 15 min";
    Timer = { OnBootSec = "2min"; OnUnitActiveSec = "15min"; Persistent = true; };
    Install.WantedBy = [ "timers.target" ];
  };
}
