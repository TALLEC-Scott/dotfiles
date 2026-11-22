{ config, pkgs, ... }:
let
  # WireGuard peer "scott-wsl" from the Freebox (keys in sops). Only these go through
  # the tunnel; everything else (and DNS) stays on the normal connection.
  wgConf = config.sops.secrets.wireguard_wsl.path;
  allowed = "212.27.38.253/32, 192.168.0.254/32"; # mafreebox.freebox.fr, Freebox LAN
  iface = "wgnas";
  dir = "/run/vpn-nas";
  wg-quick = "${pkgs.wireguard-tools}/bin/wg-quick";

  vpn-nas = pkgs.writeShellScriptBin "vpn-nas" ''
    # WireGuard to the Freebox; routes only mafreebox.freebox.fr.  vpn-nas up | down | status
    set -euo pipefail
    ip=${pkgs.iproute2}/bin/ip
    isup() { $ip link show ${iface} >/dev/null 2>&1; }
    show() { $ip -4 -o addr show ${iface} | awk '{print $2, $4}'; $ip route show dev ${iface} | sed 's/^/  route /'; }

    case "''${1:-status}" in
      up)
        if isup; then echo "already connected"; show; exit 0; fi
        [ -r "${wgConf}" ] || { echo "WireGuard config not decrypted; is the age key installed? run hms" >&2; exit 1; }
        # Freebox config, minus its DNS and AllowedIPs, plus ours
        conf=$(awk -v allowed="${allowed}" '
          /^\[Peer\]/ {print; print "AllowedIPs = " allowed; next}
          /^(DNS|AllowedIPs)[[:space:]]*=/ {next}
          {print}' "${wgConf}")
        sudo install -d -m 700 ${dir}
        printf '%s\n' "$conf" | sudo tee ${dir}/${iface}.conf >/dev/null
        sudo chmod 600 ${dir}/${iface}.conf
        sudo ${wg-quick} up ${dir}/${iface}.conf 2>&1 | grep -vE '^\[#\]' || true
        if ping -c1 -W5 192.168.0.254 >/dev/null 2>&1; then echo "connected"; show
        else echo "tunnel up but Freebox not answering; check: sudo wg show" >&2; exit 1; fi
        ;;
      down)
        if isup; then sudo ${wg-quick} down ${dir}/${iface}.conf 2>&1 | grep -vE '^\[#\]' || true; sudo rm -f ${dir}/${iface}.conf; echo "disconnected"
        else echo "not connected"; fi
        # old OpenVPN tunnel, if still running
        if [ -f /run/vpn-nas.pid ] && [ -d "/proc/$(cat /run/vpn-nas.pid)" ]; then
          sudo kill "$(cat /run/vpn-nas.pid)"; sudo rm -f /run/vpn-nas.pid; echo "stopped old OpenVPN tunnel"
        fi
        ;;
      status)
        if isup; then echo "connected"; show; else echo "not connected"; fi
        ;;
      *) echo "usage: vpn-nas up|down|status" >&2; exit 2 ;;
    esac
  '';
in
{
  sops.secrets.wireguard_wsl = { };
  sops.secrets.wireguard_windows = { };   # backup, for re-creating the Windows tunnels
  home.packages = [ vpn-nas pkgs.wireguard-tools ];
}
