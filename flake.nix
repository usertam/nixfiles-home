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
    desktop = true;
  in {
    packages = forAllSystems (system: {
      homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration rec {
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {
          inherit inputs username desktop;
        };
        modules = [
          ./programs/home.nix
          ./programs/common.nix
          ./programs/broot.nix
          ./programs/direnv.nix
          ./programs/git.nix
          ./programs/htop.nix
          ./programs/kitty.nix
          ./programs/nix.nix
          ./programs/nix-index-db.nix
          ./programs/rbw.nix
          ./programs/ssh.nix
          ./programs/zsh.nix
        ] ++ (pkgs.lib.optionals desktop [
          ./programs/fonts.nix
          ./programs/vscodium.nix
        ]) ++ (pkgs.lib.optionals (desktop && pkgs.stdenv.isLinux) [
          ./programs/chromium.nix
          ./programs/vlc.nix
        ]);
      };
    });
  };
}
