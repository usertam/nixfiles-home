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

  # The App Management check touches .DS_Store in every app bundle on every switch,
  # briefly invalidating their signatures. On a running Ghostty with LSEnvironment,
  # this can leave lsd stuck re-registering it forever at ~90% CPU.
  targets.darwin.copyApps.enableChecks = false;
}
