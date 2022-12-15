{ pkgs, ... }:

{
  home.packages = let

    # non-variable noto cjk sans.
    noto-fonts-cjk-sans-static = pkgs.noto-fonts-cjk-sans.overrideAttrs (final: prev: {
      src = pkgs.fetchFromGitHub {
        owner = "googlefonts";
        repo = "noto-cjk";
        rev = "9f7f3c38eab63e1d1fddd8d50937fe4f1eacdb1d";
        sha256 = "sha256-pNC/WJCYHSlU28E/CSFsrEMbyCe/6tjevDlOvDK9RwU=";
        sparseCheckout = [ "Sans/OTC" ];
      };
      installPhase = ''
        install -m444 -Dt $out/share/fonts/opentype/noto-cjk Sans/OTC/*.ttc
      '';
    });

    # non-variable noto cjk serif.
    noto-fonts-cjk-serif-static = pkgs.noto-fonts-cjk-serif.overrideAttrs (final: prev: {
      src = pkgs.fetchFromGitHub {
        owner = "googlefonts";
        repo = "noto-cjk";
        rev = "9f7f3c38eab63e1d1fddd8d50937fe4f1eacdb1d";
        sha256 = "sha256-Iy4lmWj5l+/Us/dJJ/Jl4MEojE9mrFnhNQxX2zhVngY=";
        sparseCheckout = [ "Serif/OTC" ];
      };
      installPhase = ''
        install -m444 -Dt $out/share/fonts/opentype/noto-cjk Serif/OTC/*.ttc
      '';
    });

    # san francisco pro family.
    sf-pro = pkgs.stdenvNoCC.mkDerivation {
      pname = "sf-pro";
      version = "220831"; # curl -v ... 2>&1 | grep Last-Modified
      src = pkgs.fetchurl {
        url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
        sha256 = "sha256-g/eQoYqTzZwrXvQYnGzDFBEpKAPC8wHlUw3NlrBabHw=";
      };
      buildInputs = [ pkgs.p7zip ];
      unpackPhase = ''
        7z x $src
        7z x 'SFProFonts/SF Pro Fonts.pkg'
        7z x 'Payload~'
      '';
      installPhase = ''
        install -m444 -Dt $out/share/fonts/opentype/sf-pro Library/Fonts/*.otf
        install -m444 -Dt $out/share/fonts/truetype/sf-pro Library/Fonts/*.ttf
      '';
    };

  in with pkgs; [
    fira-code
    fira-code-symbols
    libertinus
    noto-fonts
    noto-fonts-cjk-sans-static
    noto-fonts-cjk-serif-static
    noto-fonts-emoji
    sf-pro
  ];

  # Enable fontconfig configuration.
  fonts.fontconfig.enable = true;
}
