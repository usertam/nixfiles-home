{ lib, pkgs, ... }:

{
  nix = {
    package =
      let
        src = pkgs.fetchFromGitHub {
          owner = "DeterminateSystems";
          repo = "nix-src";
          tag = "v3.15.1";
          hash = "sha256-GsC52VFF9Gi2pgP/haQyPdQoF5Qe2myk1tsPcuJZI28=";
        };
        patch = pkgs.fetchpatch {
          url = "https://github.com/usertam/nix/commit/1de8514b4949255f7d9a33f4606ed27ac0282ecc.patch";
          hash = "sha256-/d1m8ayMPBkih5cnAfM6BmV8yUFUoWtfi9ZUTwzQ8bs=";
        };
        nixComponents' = (pkgs.nixVersions.nixComponents_git.override {
          inherit src;
          version = "2.33.0";
        }).appendPatches [ patch ];
      in
      nixComponents'.nix-everything.overrideAttrs (prev: {
        doCheck = false;
        doInstallCheck = false;
      });

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

    settings = {
      experimental-features = [
        "nix-command" "flakes"
      ];
      eval-cores = 0;     # For detsys nix only; enable parallel evaluation.
      lazy-trees = true;  # For detsys nix only.
    };
  };
}
