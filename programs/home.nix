{ pkgs, username, ... }:

{
  # Metadata.
  home.stateVersion = "22.11";
  home.username = username;
  home.homeDirectory = if pkgs.stdenv.isDarwin
    then "/Users/${username}"
    else "/home/${username}";
  programs.home-manager.enable = true;
  news.display = "silent";
}
