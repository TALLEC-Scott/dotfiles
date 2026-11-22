{ pkgs, ... }:
{
  # Personal: secrets (sops), home VPN, NAS, KeePassXC sync. Needs the age key.
  imports = [ ./secrets.nix ./vpn.nix ./nas.nix ];
  home.packages = with pkgs; [ sops age keepassxc ];
}
