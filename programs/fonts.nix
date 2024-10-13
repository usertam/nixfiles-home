{ pkgs, ... }:

{
  home.packages = let

    # Static Noto CJK Sans.
    noto-fonts-cjk-sans-static = pkgs.noto-fonts-cjk-sans.overrideAttrs (prev: {
      src = pkgs.fetchFromGitHub {
        owner = "googlefonts";
        repo = "noto-cjk";
        rev = "9f7f3c38eab63e1d1fddd8d50937fe4f1eacdb1d";
        hash = "sha256-pNC/WJCYHSlU28E/CSFsrEMbyCe/6tjevDlOvDK9RwU=";
        sparseCheckout = [ "Sans/OTC" ];
      };
      installPhase = ''
        install -m444 -Dt $out/share/fonts/opentype/noto-cjk Sans/OTC/*.ttc
      '';
    });

    # Static Noto CJK Serif.
    noto-fonts-cjk-serif-static = pkgs.noto-fonts-cjk-serif.overrideAttrs (prev: {
      src = pkgs.fetchFromGitHub {
        owner = "googlefonts";
        repo = "noto-cjk";
        rev = "9f7f3c38eab63e1d1fddd8d50937fe4f1eacdb1d";
        hash = "sha256-Iy4lmWj5l+/Us/dJJ/Jl4MEojE9mrFnhNQxX2zhVngY=";
        sparseCheckout = [ "Serif/OTC" ];
      };
      installPhase = ''
        install -m444 -Dt $out/share/fonts/opentype/noto-cjk Serif/OTC/*.ttc
      '';
    });

    # Brass Mono.
    brass-mono = pkgs.stdenvNoCC.mkDerivation (final: {
      pname = "brass-mono";
      version = "1.100";
      src = pkgs.fetchzip {
        url = "https://github.com/fonsecapeter/brass_mono/releases/download/v${final.version}/BrassMono.zip";
        hash = "sha256-viGI+vYvQ3D3PucZuw6m3dW0UqgdpWzXFDvsScC8IDQ=";
        stripRoot = false;
      };
      installPhase = ''
        install -Dm444 -t $out/share/fonts/truetype *.ttf
      '';
    });

  in with pkgs; [
    brass-mono
    fira-code
    libertinus
    noto-fonts-cjk-sans-static
    noto-fonts-cjk-serif-static
  ];

  # Enable fontconfig configuration.
  fonts.fontconfig.enable = true;
}
