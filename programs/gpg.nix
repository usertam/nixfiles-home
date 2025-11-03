{ pkgs, ... }:

{
  programs.gpg = {
    enable = true;
    settings.digest-algo = "SHA512";
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = if pkgs.stdenv.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-curses;
  };
}
