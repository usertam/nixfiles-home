{ pkgs, username, ... }:

{
  # Metadata.
  home.stateVersion = "26.05";
  home.username = username;
  home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${username}"
    else "/home/${username}";
  programs.home-manager.enable = true;
  news.display = "silent";
}
