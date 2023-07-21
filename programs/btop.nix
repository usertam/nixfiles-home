{ pkgs, ... }:

{
  programs.btop = {
    enable = true;
    package = pkgs.btop.overrideAttrs (prev: {
      patches = (prev.patches or []) ++ [
        (pkgs.fetchpatch {
          url = "https://github.com/usertam/btop/commit/5d9f691a24cafce8b3d82e6715c53d512b3e2f71.patch";
          hash = "sha256-U+dccX9UTplH/9yQlnoAV2Pdc3oQ/Uj9DlSjPp79vis=";
        })
      ];
    });
  };
}
