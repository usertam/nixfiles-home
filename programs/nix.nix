{ pkgs, lock, ... }:

{
  nix.package = pkgs.nix;
  nix.registry.nixpkgs = {
    from = {
      type = "indirect";
      id = "nixpkgs";
    };
    to = {
      type = "github";
      owner = "nixos";
      repo = "nixpkgs";
      inherit (lock.nodes.nixpkgs.locked) rev;
    };
  };
  nix.settings = {
    trusted-substituters = [
      "https://context-minimals.cachix.org"
    ];
    trusted-public-keys = [
      "context-minimals.cachix.org-1:pYxyH24J/A04fznRlYbTTjWrn9EsfUQvccGMjfXMdj0="
    ];
  };
}
