{ pkgs, ... }:

{
  home.packages = [ pkgs.nano ];

  home.file.".nanorc".text = ''
    include "${pkgs.nano}/share/nano/*.nanorc"
    include "${pkgs.nano}/share/nano/extra/*.nanorc"
  '';
}
