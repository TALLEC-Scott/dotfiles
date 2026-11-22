{ config, pkgs, ... }:
let
  # WireGuard peer "scott-wsl" from the Freebox (keys in sops), run rootless with wireproxy.
  # Nothing is routed system-wide: only programs using the SOCKS5 proxy go out through home
  # (rclone for nas/kp-sync, Firefox for Netflix + mafreebox via windows/home.pac).
  wgConf = config.sops.secrets.wireguard_wsl.path;
  proxy = "127.0.0.1:41080";
  freebox = "212.27.38.253"; # mafreebox.freebox.fr, also the Freebox DNS
  confFile = "%t/vpn-nas/wireproxy.conf"; # %t = $XDG_RUNTIME_DIR

  # Freebox config, with our AllowedIPs/DNS, a SOCKS5 listener, and MTU 1200:
  # the Freebox's 1360 is too big on some networks (large TLS handshakes, e.g. Firefox, hang)
  mkConf = pkgs.writeShellScript "vpn-nas-conf" ''
    set -eu
    out="$1"; mkdir -p "$(dirname "$out")"; chmod 700 "$(dirname "$out")"
    umask 077
    ${pkgs.gawk}/bin/awk '
      /^\[Interface\]/ {print; print "DNS = ${freebox}"; print "MTU = 1200"; next}
      /^\[Peer\]/ {print; print "AllowedIPs = 0.0.0.0/0"; next}
      /^(DNS|AllowedIPs|MTU)[[:space:]]*=/ {next} {print}
      END {print "\n[Socks5]\nBindAddress = ${proxy}"}' "${wgConf}" > "$out"
  '';

  vpn-nas = pkgs.writeShellScriptBin "vpn-nas" ''
    # vpn-nas up | down | status | check | proxy   (systemd user service "vpn-nas")
    set -euo pipefail
    sc() { systemctl --user "$@"; }
    active() { sc -q is-active vpn-nas; }
    check() { active && ${pkgs.netcat-openbsd}/bin/nc -z -w5 -X 5 -x ${proxy} ${freebox} 21 2>/dev/null; }
    case "''${1:-status}" in
      up)
        sc start vpn-nas
        for _ in $(seq 1 10); do check && { echo "connected (SOCKS5 ${proxy})"; exit 0; }; sleep 1; done
        echo "started, but the Freebox isn't answering (journalctl --user -u vpn-nas)" >&2; exit 1 ;;
      down) sc stop vpn-nas; echo "disconnected" ;;
      status) if active; then echo "connected (SOCKS5 ${proxy})"; else echo "not connected"; fi ;;
      check) check ;;
      proxy) active && echo "${proxy}" ;;   # the SOCKS5 proxy, for rclone
      *) echo "usage: vpn-nas up | down | status | check | proxy" >&2; exit 2 ;;
    esac
  '';
in
{
  sops.secrets.wireguard_wsl = { };
  sops.secrets.wireguard_windows = { };   # backup, for re-creating the Windows tunnels
  home.packages = [ vpn-nas ];

  systemd.user.services.vpn-nas = {
    Unit = { Description = "WireGuard to the Freebox (wireproxy SOCKS5 ${proxy})"; After = [ "sops-nix.service" ]; Wants = [ "sops-nix.service" ]; };
    Service = {
      ExecStartPre = "${mkConf} ${confFile}";
      ExecStart = "${pkgs.wireproxy}/bin/wireproxy -s -c ${confFile}";
      ExecStopPost = "${pkgs.coreutils}/bin/rm -f ${confFile}";
      Restart = "on-failure";
      RestartSec = 10;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
