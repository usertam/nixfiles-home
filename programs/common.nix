{ pkgs, lib, graphical, ... }:

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
    gdb
    imagemagick
    lesspipe
    nano
    podman-compose
    podman-tui
    rclone
    streamlink
  ] ++ (lib.optionals pkgs.stdenv.isLinux [
    progress
  ]) ++ (lib.optionals (graphical && pkgs.stdenv.isLinux) [
    discord
    latte-dock
    obs-studio
    vmware-workstation
  ]);
}
