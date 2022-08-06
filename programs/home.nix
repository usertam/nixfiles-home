{ username, ... }:

{
  # Metadata.
  home.stateVersion = "22.11";
  home.username = username;
  home.homeDirectory = "/home/${username}";
}
