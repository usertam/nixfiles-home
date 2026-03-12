{ lib, pkgs, ... }:

{
  nix = {
    # Use lix as default nix impl.
    package = pkgs.lixPackageSets.latest.lix;

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
    };
  };
}
