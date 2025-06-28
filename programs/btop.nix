{ pkgs, ... }:

{
  programs.btop = {
    enable = true;
    package = pkgs.btop.overrideAttrs (prev: {
      patches = (prev.patches or []) ++ [
        (pkgs.fetchpatch {
          url = "https://github.com/usertam/btop/commit/68aed42f33071071d1d9bc03f3be5fb25fa5dfc6.patch";
          hash = "sha256-RBz+6XZAJZrNXAlHGO5eKtuQl4/9ZMa0OhQtm6g6oGE=";
        })
      ];
    });
  };
}
