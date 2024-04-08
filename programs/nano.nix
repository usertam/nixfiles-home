{ pkgs, ... }:

{
  home.packages = [ pkgs.nano ];

  home.file.".nanorc" = {
    source = pkgs.writeText "nanorc" ''
      include "${pkgs.nano}/share/nano/*.nanorc"
      include "${pkgs.nano}/share/nano/extra/*.nanorc"
    '';
  };
}
