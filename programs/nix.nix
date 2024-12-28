{ lib, pkgs, ... }:

{
  nix = {
    # Use bleeding-edge version of nix, patched with usertam/nix/what-the-hack.
    package = pkgs.nixVersions.git.overrideAttrs (prev: {
      patches = (prev.patches or []) ++ lib.singleton (pkgs.fetchpatch {
        url = "https://github.com/NixOS/nix/compare/bff9296...usertam:nix:db13dbb.patch";
        hash = "sha256-LmLDPaDsUCNFvvFvx8qcC2rWJzxHkcn984HqW+38RHU=";
      });
      doCheck = false;
      doInstallCheck = false;
    });

    # For insane system nix config.
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
