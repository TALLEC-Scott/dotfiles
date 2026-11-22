{ pkgs, ... }:
{
  # Needs the age key (~/.config/sops/age/keys.txt)
  imports = [ ./secrets.nix ./vpn.nix ./nas.nix ];
  home.packages = with pkgs; [ sops age keepassxc ];
}
