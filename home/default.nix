{ pkgs, username, homeDirectory, ... }:
{
  imports = [
    ./packages.nix
    ./bash.nix
    ./vim.nix
    ./files.nix
    ./secrets.nix
    ./vpn.nix
    ./nas.nix
  ];

  home = {
    inherit username homeDirectory;
    stateVersion = "25.05";
  };

  # Lets Home Manager work on non-NixOS distros (XDG_DATA_DIRS, locales, etc.)
  targets.genericLinux.enable = pkgs.stdenv.hostPlatform.isLinux;

  # Keep flakes enabled for the user regardless of the system nix.conf
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings.core.editor = "vim";
  };

  fonts.fontconfig.enable = true;
}
