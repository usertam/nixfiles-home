{ lib, pkgs, ... }:

{
  nix = {
    # Use unstable version of nix.
    package = pkgs.nixVersions.unstable;

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
      extra-trusted-substituters = [
        "https://context-minimals.cachix.org"
      ];
      extra-trusted-public-keys = [
        "context-minimals.cachix.org-1:pYxyH24J/A04fznRlYbTTjWrn9EsfUQvccGMjfXMdj0="
      ];
    };
  };
}
