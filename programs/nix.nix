{ lib, pkgs, ... }:

{
  nix = {
    # Use bleeding-edge version of nix, patched with what-the-hack.
    package = (pkgs.nixVersions.nixComponents_2_29.appendPatches [
      (pkgs.fetchpatch {
        url = "https://github.com/NixOS/nix/compare/master...usertam:nix:ad2869d.patch";
        hash = "sha256-nG403Ex/w3CnsNd7+c0HFDuwbe68OazvGuASFXYZZI8=";
      })
    ]).nix-everything.overrideAttrs (prev: {
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
