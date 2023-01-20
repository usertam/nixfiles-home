{ pkgs, ... }:

{
  nix.package = pkgs.nix;
  nix.settings = {
    trusted-substituters = [
      "https://context-minimals.cachix.org"
    ];
    trusted-public-keys = [
      "context-minimals.cachix.org-1:pYxyH24J/A04fznRlYbTTjWrn9EsfUQvccGMjfXMdj0="
    ];
  };
}
