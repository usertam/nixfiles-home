{ pkgs, ... }:

{
  home.packages = let

    # Static Noto CJK Sans and Sans Serif.
    noto-fonts-cjk-sans-and-serif-static = pkgs.stdenvNoCC.mkDerivation {
      pname = "noto-fonts-cjk-sans-and-serif-static";
      version = "2.003-unstable-2025-10-18";
      src = pkgs.fetchFromGitHub {
        owner = "notofonts";
        repo = "noto-cjk";
        rev = "f8d157532fbfaeda587e826d4cd5b21a49186f7c";
        hash = "sha256-sflNY5J+K07v1uUvOkeSlpQJoghXRR0oJjASKXT71Nw=";
        sparseCheckout = [ "Sans/OTC" "Serif/OTC" ];
      };
      installPhase = ''
        install -Dm444 -t $out/share/fonts/opentype/noto-cjk {Sans,Serif}/OTC/*.ttc
      '';
      meta = {
        inherit (pkgs.noto-fonts-cjk-sans.meta)
          description
          longDescription
          homepage
          license
          platforms;
      };
    };

    # Brass Mono.
    brass-mono = pkgs.stdenvNoCC.mkDerivation (final: {
      pname = "brass-mono";
      version = "1.101";
      src = pkgs.fetchzip {
        url = "https://github.com/fonsecapeter/brass_mono/releases/download/v${final.version}/BrassMono.zip";
        hash = "sha256-XamUFHuVRnCUadLdERG9AipiRGWe88+CdxY6+FFyerE=";
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
    noto-fonts-cjk-sans-and-serif-static
  ];

  # Enable fontconfig configuration.
  fonts.fontconfig.enable = true;
}
