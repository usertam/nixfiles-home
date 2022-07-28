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
    nix-index-db.url = "github:usertam/nix-index-database-trial/standalone/nixpkgs-unstable";
    nix-index-db.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, nix-index-db, ... }:
    let
      username = "tam";
      system = "x86_64-linux";
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { inherit username nix-index-db; };
        modules = [
          ./programs/common.nix
          ./programs/broot.nix
          ./programs/chromium.nix
          ./programs/direnv.nix
          ./programs/fonts.nix
          ./programs/git.nix
          ./programs/htop.nix
          ./programs/kitty.nix
          ./programs/nix-index-db.nix
          ./programs/rbw.nix
          ./programs/ssh.nix
          ./programs/vlc.nix
          ./programs/vscodium.nix
        ];
      };
    };
}
