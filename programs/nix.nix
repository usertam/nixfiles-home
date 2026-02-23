{ lib, pkgs, ... }:

{
  nix = {
    package =
      let
        src = pkgs.fetchFromGitHub {
          owner = "DeterminateSystems";
          repo = "nix-src";
          tag = "v3.16.1";
          hash = "sha256-UAvzXk5s7y6RPYB7isRFDe/Y20U9iK8f0NH+sfV7yPU=";
        };
        patch = pkgs.fetchpatch {
          url = "https://github.com/usertam/nix/commit/1de8514b4949255f7d9a33f4606ed27ac0282ecc.patch";
          hash = "sha256-/d1m8ayMPBkih5cnAfM6BmV8yUFUoWtfi9ZUTwzQ8bs=";
        };
      in
      ((pkgs.nixVersions.nixComponents_git.overrideSource src).appendPatches [ patch ])
      .nix-everything.overrideAllMesonComponents (final: prev: {
        buildInputs = (prev.buildInputs or [ ]) ++ lib.optional (lib.elem final.pname [ "nix-store" "nix-expr" ]) pkgs.wasmtime;
        mesonFlags = (prev.mesonFlags or [ ]) ++ lib.optional (lib.elem final.pname [ "nix-store" "nix-expr" ]) (lib.mesonEnable "wasm" true);
        version = "2.33.3";
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
