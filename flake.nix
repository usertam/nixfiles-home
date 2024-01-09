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
    nix-index-db.url = "github:usertam/nix-index-db/standalone/nixpkgs-unstable";
    nix-index-db.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: let
    forAllSystems = with inputs.nixpkgs.lib; genAttrs platforms.unix;
    username = "tam";
  in {
    packages = forAllSystems (system: {
      homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration rec {
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {
          inherit inputs username;
          lock = inputs.nixpkgs.lib.importJSON ./flake.lock;
        };
        modules = [
          ./programs/home.nix
          ./programs/common.nix
          ./programs/broot.nix
          ./programs/btop.nix
          ./programs/direnv.nix
          ./programs/fonts.nix
          ./programs/git.nix
          ./programs/kitty.nix
          ./programs/nix.nix
          ./programs/nix-index-db.nix
          ./programs/rbw.nix
          ./programs/ssh.nix
          ./programs/vscodium.nix
          ./programs/zsh.nix
        ];
      };
    });
  };
}
