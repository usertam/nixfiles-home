{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    font = {
      package = pkgs.fira-code;
      name = "Fira Code Medium";
      size = 12;
    };
    extraConfig = ''
      bold_font                   Fira Code SemiBold
      cursor_shape                underline
      shell_integration           disabled
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
        font_size                   14
        window_padding_width        12.5
      ''
      else ''
        initial_window_width        750
        initial_window_height       500
        window_padding_width        10
      ''
    );
  };
}
