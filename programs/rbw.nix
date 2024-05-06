{ pkgs, ... }:

{
  programs.rbw = {
    enable = true;
    settings.email = "heiyiutam@gmail.com";
    settings.pinentry = pkgs.pinentry-tty;
  };
}
