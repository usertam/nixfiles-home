{ config, lib, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
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
        map cmd+t     new_tab_with_cwd
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
