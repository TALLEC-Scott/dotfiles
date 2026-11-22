{
  description = "Scott's distro-agnostic dotfiles (Home Manager)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, sops-nix, ... }:
    let
      # Profiles = sets of modules. Pick one: home-manager switch --flake .#<profile>
      profiles = {
        scott = [ ./home/base ./home/dev.nix ./home/personal ];  # this PC
        work = [ ./home/base ./home/dev.nix ];                    # company machine: no personal secrets/VPN
        server = [ ./home/base ./home/personal ];                 # NAS + backups, no toolchains
        minimal = [ ./home/base ];
      };

      mkHome = { modules, system ? "x86_64-linux", username ? "scott" }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
          extraSpecialArgs = { inherit username; homeDirectory = "/home/${username}"; };
          modules = [ sops-nix.homeManagerModules.sops ] ++ modules;
        };
    in
    {
      homeConfigurations = builtins.mapAttrs (_: modules: mkHome { inherit modules; }) profiles // {
        # Other CPUs / usernames: add entries like these
        server-arm = mkHome { modules = profiles.server; system = "aarch64-linux"; };  # Raspberry Pi
      };
    };
}
