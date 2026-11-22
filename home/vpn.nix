{ config, pkgs, ... }:
let
  # WireGuard peer "scott-wsl" from the Freebox (keys in sops), run rootless with wireproxy.
  # Nothing is routed system-wide: only programs using the SOCKS5 proxy go out through home
  # (rclone for nas/kp-sync, Firefox for Netflix via windows/netflix.pac).
  wgConf = config.sops.secrets.wireguard_wsl.path;
  allowed = "0.0.0.0/0";
  proxy = "127.0.0.1:41080";

  vpn-nas = pkgs.writeShellScriptBin "vpn-nas" ''
    # vpn-nas up | down | status | check | proxy
    set -euo pipefail
    run="''${XDG_RUNTIME_DIR:-$HOME/.cache}/vpn-nas"
    pidf="$run/wireproxy.pid"
    running() { [ -f "$pidf" ] && [ -d "/proc/$(cat "$pidf")" ]; }
    check() { running && ${pkgs.netcat-openbsd}/bin/nc -z -w5 -X 5 -x ${proxy} 212.27.38.253 21 2>/dev/null; }

    case "''${1:-status}" in
      up)
        if running; then echo "connected (SOCKS5 ${proxy})"; exit 0; fi
        [ -r "${wgConf}" ] || { echo "WireGuard config not decrypted; is the age key installed? run hms" >&2; exit 1; }
        mkdir -p "$run"; chmod 700 "$run"
        # Freebox config, with our AllowedIPs/DNS, a SOCKS5 listener, and MTU 1200:
        # the Freebox's 1360 is too big on some networks (large TLS handshakes, e.g. Firefox, hang)
        awk -v allowed="${allowed}" '
          /^\[Interface\]/ {print; print "DNS = 212.27.38.253"; print "MTU = 1200"; next}
          /^\[Peer\]/ {print; print "AllowedIPs = " allowed; next}
          /^(DNS|AllowedIPs|MTU)[[:space:]]*=/ {next} {print}
          END {print "\n[Socks5]\nBindAddress = ${proxy}"}' "${wgConf}" > "$run/wireproxy.conf"
        chmod 600 "$run/wireproxy.conf"
        nohup ${pkgs.wireproxy}/bin/wireproxy -s -c "$run/wireproxy.conf" >"$run/wireproxy.log" 2>&1 &
        echo $! > "$pidf"
        for _ in $(seq 1 10); do check && { echo "connected (SOCKS5 ${proxy})"; exit 0; }; sleep 1; done
        echo "started, but the Freebox isn't answering (log: $run/wireproxy.log)" >&2; exit 1
        ;;
      down)
        if running; then kill "$(cat "$pidf")"; rm -f "$pidf" "$run/wireproxy.conf"; echo "disconnected"
        else echo "not connected"; fi
        ;;
      status) if running; then echo "connected (SOCKS5 ${proxy})"; else echo "not connected"; fi ;;
      check) check ;;                       # exit 0 if the Freebox is reachable
      proxy) running && echo "${proxy}" ;;  # the SOCKS5 proxy, for rclone
      *) echo "usage: vpn-nas up | down | status | check | proxy" >&2; exit 2 ;;
    esac
  '';
in
{
  sops.secrets.wireguard_wsl = { };
  sops.secrets.wireguard_windows = { };   # backup, for re-creating the Windows tunnels
  home.packages = [ vpn-nas ];
}
