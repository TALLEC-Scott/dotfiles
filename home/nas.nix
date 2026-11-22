{ config, pkgs, ... }:
let
  # "login\npassword" for the Freebox FTP server, from sops
  auth = config.sops.secrets.nas_ftp_auth.path;
  host = "192.168.0.254"; # Freebox on the home LAN (reach it with: vpn-nas up)

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
        export RCLONE_CONFIG_NAS_TYPE=ftp RCLONE_CONFIG_NAS_HOST=${host}
        RCLONE_CONFIG_NAS_USER=$(sed -n 1p "${auth}"); export RCLONE_CONFIG_NAS_USER
        RCLONE_CONFIG_NAS_PASS=$(sed -n 2p "${auth}" | $rclone obscure -); export RCLONE_CONFIG_NAS_PASS
        mkdir -p "$mnt" "$(dirname "$log")"
        $rclone mount nas: "$mnt" --daemon --vfs-cache-mode writes \
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
  home.packages = [ nas pkgs.rclone ];
}
