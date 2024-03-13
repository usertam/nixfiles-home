{ pkgs, ... }:

{
  programs.btop = {
    enable = true;
    package = pkgs.btop.overrideAttrs (prev: {
      patches = (prev.patches or []) ++ [
        (pkgs.fetchpatch {
          url = "https://github.com/usertam/btop/commit/bc79ea7c648e9c16fa0f1e4de218e608cf7630bf.patch";
          hash = "sha256-oefJ4/Ksvmnbilwgh6GTzmgAS5OhGLrDFx5gq9Nm7YI=";
        })
      ];
    });
  };
}
