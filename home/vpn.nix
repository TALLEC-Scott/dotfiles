{ config, pkgs, ... }:
let
  # Freebox OpenVPN profile (bridge/TAP). Encrypted in secrets/secrets.yaml.
  ovpn = config.sops.secrets.openvpn_nas.path;
  # "login\npassword", also from sops (no prompt)
  auth = config.sops.secrets.openvpn_nas_auth.path;

  # TAP bridge: the Freebox gives us a LAN address by DHCP. Only the LAN route is
  # added (no default gateway, resolv.conf untouched), so normal traffic is unchanged.
  up = pkgs.writeShellScript "vpn-nas-up" ''
    dev="$1"
    ${pkgs.iproute2}/bin/ip link set "$dev" up
    if ! ${pkgs.iproute2}/bin/ip -4 addr show "$dev" | grep -q inet; then
      ${pkgs.dhcpcd}/bin/dhcpcd -4 -b -q --nogateway --nohook resolv.conf "$dev"
    fi
  '';
  down = pkgs.writeShellScript "vpn-nas-down" ''
    ${pkgs.dhcpcd}/bin/dhcpcd -x "$1" 2>/dev/null || true
  '';

  vpn-nas = pkgs.writeShellScriptBin "vpn-nas" ''
    # Connect to the home network (NAS) over OpenVPN. Ctrl+C disconnects.
    set -euo pipefail
    [ -r "${ovpn}" ] && [ -r "${auth}" ] || { echo "VPN profile not decrypted (${ovpn}); is the age key installed? run hms" >&2; exit 1; }
    exec sudo ${pkgs.openvpn}/bin/openvpn \
      --config "${ovpn}" \
      --auth-user-pass "${auth}" \
      --script-security 2 --up ${up} --down ${down} \
      --auth-nocache "$@"
  '';
in
{
  sops.secrets.openvpn_nas = { };
  sops.secrets.openvpn_nas_auth = { };
  home.packages = [ vpn-nas pkgs.openvpn ];
}
