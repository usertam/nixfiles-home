# This file is part of the home-manager configuration.
# Resides in the ~/.config/nixpkgs/ directory.

# To update flake.lock, run:
# > nix flake update ~/.config/nixpkgs

# To rebuild configuration, run:
# > home-manager { switch | build }

# To import nixpkgs in `nix repl`, do:
# nix-repl> :lf nixpkgs
# nix-repl> pkgs = legacyPackages.x86_64-linux

{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      username = "tam";
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./programs/common.nix
          ./programs/broot.nix
          ./programs/chromium.nix
          ./programs/direnv.nix
          ./programs/fonts.nix
          ./programs/git.nix
          ./programs/htop.nix
          ./programs/kitty.nix
          ./programs/rbw.nix
          ./programs/ssh.nix
          ./programs/vlc.nix
          ./programs/vscodium.nix
        ];
      };
    };
}
