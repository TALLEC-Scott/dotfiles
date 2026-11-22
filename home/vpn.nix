{ config, pkgs, ... }:
let
  # Freebox OpenVPN profile (bridge/TAP). Encrypted in secrets/secrets.yaml.
  ovpn = config.sops.secrets.openvpn_nas.path;
  # fixed (locally administered) MAC so the Freebox DHCP gives the same IP each time
  mac = "02:00:5e:10:00:40";
  # "login\npassword", also from sops (no prompt)
  auth = config.sops.secrets.openvpn_nas_auth.path;

  # TAP bridge: the Freebox gives us a LAN address by DHCP. Only mafreebox.freebox.fr
  # goes through the tunnel: no LAN /24, no default gateway, no IPv6, DNS untouched.
  freeboxLan = "192.168.0.254";
  mafreebox = "212.27.38.253"; # mafreebox.freebox.fr

  # dhcpcd hook (replaces its default script): on every lease, keep only our routes
  dhcpHook = pkgs.writeShellScript "vpn-nas-dhcp-hook" ''
    ip=${pkgs.iproute2}/bin/ip
    case "$reason" in
      BOUND|RENEW|REBIND|REBOOT|STATIC)
        $ip -4 route flush dev "$interface" proto dhcp
        $ip route replace ${freeboxLan}/32 dev "$interface"
        $ip route replace ${mafreebox}/32 via ${freeboxLan} dev "$interface"
        ;;
    esac
  '';

  up = pkgs.writeShellScript "vpn-nas-up" ''
    dev="$1"
    # IPv6: no home addresses or routes over the tunnel
    ${pkgs.procps}/bin/sysctl -q -w "net.ipv6.conf.$dev.accept_ra=0"
    ${pkgs.iproute2}/bin/ip -6 route flush dev "$dev" proto ra 2>/dev/null || true
    ${pkgs.iproute2}/bin/ip link set "$dev" up
    # always get a fresh lease (an old dhcpcd may hold a stale one)
    ${pkgs.dhcpcd}/bin/dhcpcd -x "$dev" 2>/dev/null || true
    ${pkgs.dhcpcd}/bin/dhcpcd -4 -b -q --nogateway -c ${dhcpHook} "$dev"
  '';
  down = pkgs.writeShellScript "vpn-nas-down" ''
    ${pkgs.dhcpcd}/bin/dhcpcd -x "$1" 2>/dev/null || true
  '';

  vpn-nas = pkgs.writeShellScriptBin "vpn-nas" ''
    # OpenVPN to the Freebox, in the background; routes only mafreebox.freebox.fr.
    #   vpn-nas up | down | status | log
    set -euo pipefail
    pid=/run/vpn-nas.pid
    log=/run/vpn-nas.log
    ip=${pkgs.iproute2}/bin/ip

    running() { [ -f "$pid" ] && [ -d "/proc/$(cat "$pid")" ]; }
    addr() { $ip -4 -o addr show 2>/dev/null | awk '$2 ~ /^tap/ {print $2, $4}'; }

    case "''${1:-status}" in
      up)
        if running; then echo "already connected"; addr; exit 0; fi
        [ -r "${ovpn}" ] && [ -r "${auth}" ] || { echo "VPN secrets not decrypted; is the age key installed? run hms" >&2; exit 1; }
        sudo ${pkgs.openvpn}/bin/openvpn \
          --config "${ovpn}" \
          --auth-user-pass "${auth}" \
          --script-security 2 --up ${up} --down ${down} \
          --auth-nocache \
          --dev tap0 --lladdr ${mac} \
          --daemon vpn-nas --writepid "$pid" --log "$log"
        echo -n "connecting"
        for _ in $(seq 1 30); do
          if sudo grep -q "Initialization Sequence Completed" "$log" 2>/dev/null; then
            for _ in $(seq 1 15); do [ -n "$(addr)" ] && break; sleep 1; done
            echo " ok"; addr; exit 0
          fi
          if ! running; then echo " failed"; sudo tail -n 15 "$log"; exit 1; fi
          echo -n "."; sleep 1
        done
        echo " timeout (still trying in background; see: vpn-nas log)"; exit 1
        ;;
      down)
        if running; then sudo kill "$(cat "$pid")"; sleep 1; sudo rm -f "$pid"; echo "disconnected"
        else echo "not connected"; fi
        ;;
      status)
        if running; then echo "connected (pid $(cat "$pid"))"; addr; else echo "not connected"; fi
        ;;
      log) sudo tail -n "''${2:-30}" "$log" ;;
      *) echo "usage: vpn-nas up|down|status|log [lines]" >&2; exit 2 ;;
    esac
  '';
in
{
  sops.secrets.openvpn_nas = { };
  sops.secrets.openvpn_nas_auth = { };
  home.packages = [ vpn-nas pkgs.openvpn ];
}
