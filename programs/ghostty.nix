{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    package = with pkgs; if stdenv.isDarwin then ghostty-bin else ghostty;
    enableZshIntegration = true;
    settings = {
      theme = "TokyoNight";
      # Original #1a1b26, HSL lightness 13% -> 11%.
      background = "#171821";
      # Original #c0caf5, HSL saturation 73% -> 50%.
      foreground = "#c9d0ed";
      font-family = "Brass Mono";
      font-family-bold = "Brass Mono Bold";
      font-family-italic = "Brass Mono Italic";
      font-family-bold-italic = "Brass Mono Bold Italic";
      font-size = 16;
      window-padding-x = 14;
      window-padding-y = 10;
      cursor-style = "underline";
      cursor-style-blink = false;
      shell-integration-features = "no-cursor,ssh-env";
      window-width = 90;
      window-height = 30;
    };
  };
}
