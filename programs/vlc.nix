{ pkgs, lib, ... }:

{
  home.packages = if pkgs.stdenv.isDarwin then [
    (pkgs.vlc-bin.overrideAttrs (prev: {
      postInstall = (prev.postInstall or "") + ''
        cp -f ${pkgs.fetchurl {
          url = "https://code.videolan.org/-/project/435/uploads/f5b752f5ffb64c37cd62f480e0713b5a/VLC.icns";
          hash = "sha256-v1R+rxgAkMom8PRvniKUcHJZDpCSjNpw781c1QCk71U=";
        }} $out/Applications/VLC.app/Contents/Resources/VLC.icns
      '';
    }))
  ] else [
    pkgs.vlc
  ];

  # Write vlc configurations.
  xdg.configFile."vlc/vlc-qt-interface.conf" = lib.mkIf pkgs.stdenv.isLinux {
    text = lib.generators.toINI {} {
      "MainWindow" = {
        "AdvToolbar" = "\"11-5;13-5;14-5;\"";
        "FSCtoolbar" = "\"0-5;33;34-4;35-4;\"";
        "InputToolbar" = "";
        "MainToolbar1" = "";
        "MainToolbar2" = "\"0-5;43;33;44;64-4;35-4;\"";
        "adv-controls" = "0";
      };
    };
  };
  xdg.configFile."vlc/vlcrc" = lib.mkIf pkgs.stdenv.isLinux {
    text = lib.generators.toINI {} {
      "gl" = {
        "tone-mapping" = "2";
        "tone-mapping-param" = "0.750000";
      };
      "freetype" = {
        "freetype-font" = "Noto Sans CJK HK Medium";
        "freetype-monofont" = "Noto Sans Mono Medium";
        "freetype-rel-fontsize" = "20";
        "freetype-outline-thickness" = "2";
      };
      "qt" = {
        "qt-video-autoresize" = "0";
        "qt-privacy-ask" = "0";
      };
      "core" = {
        "custom-crop-ratios" = "19:10";
        "text-renderer" = "freetype";
        "one-instance-when-started-from-file" = "0";
        "sub-language" = "ENG";
      };
    };
  };
}
