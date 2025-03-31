{ lib, pkgs, ... }:

{
  nix = {
    # Use bleeding-edge version of nix, patched with what-the-hack.
    package = pkgs.nixVersions.latest.overrideAttrs (prev: {
      patches = (prev.patches or []) ++ lib.singleton (pkgs.fetchpatch {
        url = "https://github.com/NixOS/nix/compare/442a262...usertam:nix:7be2ce9.patch";
        hash = "sha256-W7aU1LTYSrQWRjeHEXhb34Aux+T3pXrfO0dNdE+zsvY=";
      });
      doCheck = false;
      doInstallCheck = false;
    });

    # In case we have a diabolical system nix config.
    settings.extra-experimental-features = [ "nix-command" "flakes" ];

    # Lock nixpkgs in registry.
    registry.nixpkgs = {
      from = {
        type = "indirect";
        id = "nixpkgs";
      };
      to = let
        lock = lib.importJSON ../flake.lock;
      in {
        inherit (lock.nodes.nixpkgs.locked) rev;
        type = "github";
        owner = "nixos";
        repo = "nixpkgs";
      };
    };
  };
}
