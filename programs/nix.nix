{ lib, pkgs, ... }:

{
  nix = {
    # Use bleeding-edge version of nix, patched with what-the-hack.
    package = (pkgs.nixVersions.latest.appendPatches [
      (pkgs.fetchpatch {
        url = "https://github.com/NixOS/nix/compare/3f13cc0f8...usertam:nix:ecac5de06.patch";
        hash = "sha256-kncSW90+ygIfAVXUFSNxqEzB8AiTQosPCiPdrywhPMM=";
      })
    ]).overrideAttrs (prev: {
      doCheck = pkgs.stdenv.isLinux;
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
