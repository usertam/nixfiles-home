{ lib, pkgs, ... }:

{
  nix = {
    package =
      let
        src = pkgs.fetchFromGitHub {
          owner = "DeterminateSystems";
          repo = "nix-src";
          tag = "v3.11.2";
          hash = "sha256-3Ia+y7Hbwnzcuf1hyuVnFtbnSR6ErQeFjemHdVxjCNE=";
        };
        patch = pkgs.fetchpatch {
          url = "https://github.com/usertam/nix/compare/3eeb09f~5...3eeb09f.patch";
          hash = "sha256-gASz7PC17+GkNGWNXb93h0r/sVINU9yKYEp/whjI3tA=";
        };
        nixComponents' = (pkgs.nixVersions.nixComponents_git.override {
          inherit src;
          version = "2.31.1";
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
