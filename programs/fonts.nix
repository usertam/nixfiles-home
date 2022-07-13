{ pkgs, ... }:

{
  home.packages = let
    # use non-variable noto-fonts-cjk fonts.
    noto-fonts-cjk-sans-static = pkgs.noto-fonts-cjk-sans.overrideAttrs (final: prev: {
      src = pkgs.fetchFromGitHub {
        owner = "googlefonts";
        repo = "noto-cjk";
        rev = "9f7f3c38eab63e1d1fddd8d50937fe4f1eacdb1d";
        sha256 = "sha256-pNC/WJCYHSlU28E/CSFsrEMbyCe/6tjevDlOvDK9RwU=";
        sparseCheckout = "Sans/OTC";
      };
      installPhase = ''
        install -m444 -Dt $out/share/fonts/opentype/noto-cjk Sans/OTC/*.ttc
      '';
    });
    noto-fonts-cjk-serif-static = pkgs.noto-fonts-cjk-serif.overrideAttrs (final: prev: {
      src = pkgs.fetchFromGitHub {
        owner = "googlefonts";
        repo = "noto-cjk";
        rev = "9f7f3c38eab63e1d1fddd8d50937fe4f1eacdb1d";
        sha256 = "sha256-Iy4lmWj5l+/Us/dJJ/Jl4MEojE9mrFnhNQxX2zhVngY=";
        sparseCheckout = "Serif/OTC";
      };
      installPhase = ''
        install -m444 -Dt $out/share/fonts/opentype/noto-cjk Serif/OTC/*.ttc
      '';
    });
  in with pkgs; [
    fira-code
    fira-code-symbols
    noto-fonts
    noto-fonts-cjk-sans-static
    noto-fonts-cjk-serif-static
    noto-fonts-emoji
    noto-fonts-extra
  ];

  # Enable fontconfig configuration.
  fonts.fontconfig.enable = true;
}
