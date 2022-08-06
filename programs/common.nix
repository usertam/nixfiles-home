{ pkgs, lib, ... }:

{
  # Allow unfree packages.
  nixpkgs.config.allowUnfreePredicate = pkg: true;
  # builtins.elem (lib.getName pkg) [
  #   "discord"
  #   "vmware-workstation"
  # ];

  home.packages = with pkgs; [
    axel
    clang
    ccache
    discord
    gdb
    imagemagick
    latte-dock
    lesspipe
    obs-studio
    progress
    podman-compose
    podman-tui
    rclone
    streamlink
    vmware-workstation
  ];
}
