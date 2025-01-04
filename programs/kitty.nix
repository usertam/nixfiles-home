{ config, lib, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    package = pkgs.kitty.overrideAttrs (prev: rec {
      # The PR hasn't propagated to nixpkgs-unstable.
      # https://github.com/NixOS/nixpkgs/pull/368580
      version = "0.38.1";
      src = pkgs.fetchFromGitHub {
        owner = "kovidgoyal";
        repo = "kitty";
        rev = "refs/tags/v${version}";
        hash = "sha256-0M4Bvhh3j9vPedE/d+8zaiZdET4mXcrSNUgLllhaPJw=";
      };
      postPatch = (prev.postPatch or "") + ''
        # Force kitty-integration no-cursor.
        substituteInPlace shell-integration/zsh/kitty-integration \
          --replace '(( ! opt[(Ie)no-cursor] ))' 'false'
      '';
      doCheck = false;
      doInstallCheck = false;
    });
    font = {
      name = "Brass Mono Code";
      size = if pkgs.stdenv.isDarwin then 16 else 14;
    };
    extraConfig = ''
      cursor_shape                underline
      cursor_beam_thickness       1.2
      cursor_underline_thickness  1.0
      cursor_blink_interval       0
      wheel_scroll_multiplier     5.0
      touch_scroll_multiplier     5.0
      strip_trailing_spaces       smart
      remember_window_size        no
      confirm_os_window_close     0
    '' + (
      if pkgs.stdenv.isDarwin then ''
        macos_option_as_alt         yes
        window_padding_width        12.5
        map alt+left  send_text all \x1b\x62
        map alt+right send_text all \x1b\x66
        map cmd+left  send_text all \x01
        map cmd+right send_text all \x05
        map cmd+]     next_window
        map cmd+[     previous_window
      ''
      else ''
        initial_window_width        750
        initial_window_height       500
        window_padding_width        10
      ''
    );
  };

  # Include kitty terminfo.
  home.packages = [
    config.programs.kitty.package.terminfo
  ];
}
