{ pkgs, lib, username, homeDirectory, ... }:
{
  imports = [
    ./packages.nix
    ./bash.nix
    ./vim.nix
    ./files.nix
    ./secrets.nix
    ./vpn.nix
    ./nas.nix
    ./open.nix
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

  # Weekly: delete generations older than 30 days (the current one is always kept),
  # then remove Nix store files nothing uses any more.
  services.home-manager.autoExpire = {
    enable = true;
    frequency = "weekly";
    timestamp = "-30 days";
    store.cleanup = true;
  };

  # Linger: start user services (vpn-nas, kp-sync, sops-nix) at boot, not at first login.
  # Allowed without sudo where polkit permits it (Ubuntu default); otherwise just a hint.
  home.activation.linger = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v loginctl >/dev/null \
       && [ "$(loginctl show-user "$USER" -p Linger --value 2>/dev/null)" = no ]; then
      run loginctl enable-linger "$USER" 2>/dev/null \
        || echo "note: enable linger once with: sudo loginctl enable-linger $USER" >&2
    fi
  '';

  programs.git = {
    enable = true;
    settings.core.editor = "vim";
  };

  fonts.fontconfig.enable = true;
}
