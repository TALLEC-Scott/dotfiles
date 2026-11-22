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
      # One entry per machine/user. Add more (e.g. the Raspberry Pi) as needed.
      hosts = {
        scott = { system = "x86_64-linux"; username = "scott"; homeDirectory = "/home/scott"; };
        scott-arm = { system = "aarch64-linux"; username = "scott"; homeDirectory = "/home/scott"; };
      };

      mkHome = _: h: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit (h) system;
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit (h) username homeDirectory; };
        modules = [ sops-nix.homeManagerModules.sops ./home ];
      };
    in
    {
      homeConfigurations = builtins.mapAttrs mkHome hosts;
    };
}
