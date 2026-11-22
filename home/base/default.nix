{ pkgs, username, homeDirectory, ... }:
{
  # Base: shell, editor, everyday tools, Home Manager settings. Every profile includes it.
  imports = [ ./packages.nix ./bash.nix ./vim.nix ./files.nix ./open.nix ];

  home = {
    inherit username homeDirectory;
    stateVersion = "25.05";
  };

  # Lets Home Manager work on non-NixOS distros (XDG_DATA_DIRS, locales, etc.)
  targets.genericLinux.enable = pkgs.stdenv.hostPlatform.isLinux;
  # Terminal only: no Nix-provided OpenGL/Vulkan drivers (Mesa, ~1 GB). CUDA tools use the
  # system driver (on WSL: /usr/lib/wsl/lib, see bash.nix).
  targets.genericLinux.gpu.enable = false;

  # Keep flakes enabled for the user regardless of the system nix.conf
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  programs.home-manager.enable = true;

  # Weekly: delete generations older than 30 days (the current one is always kept),
  # then remove Nix store files nothing uses any more.
  services.home-manager.autoExpire = {
    enable = true;
    frequency = "weekly";
    timestamp = "-30 days";
    store.cleanup = true;
  };

  programs.git = {
    enable = true;
    settings.core.editor = "vim";
  };

  fonts.fontconfig.enable = true;
}
