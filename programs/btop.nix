{ pkgs, ... }:

{
  programs.btop = {
    enable = true;
    package = pkgs.btop.overrideAttrs (prev: {
      patches = (prev.patches or []) ++ [
        (pkgs.fetchpatch {
          url = "https://github.com/usertam/btop/commit/0d9dcbf5c977ca092ac6a5f550e0b7b9937ac6ba.patch";
          hash = "sha256-OU0m4UnzmhapPBuhm4b7cpS8bE5gnT3/cNTwHSmYinI=";
        })
      ];
    });
  };
}
