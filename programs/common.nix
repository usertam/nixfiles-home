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
    coreutils
    gdb
    gnupg
    home-manager
    imagemagick
    lesspipe
    nano
    nix-index
    openssh
    podman-compose
    podman-tui
    rclone
    rsync
  ] ++ (lib.optionals graphical [
    discord-canary
    streamlink
  ]) ++ (lib.optionals (graphical && pkgs.stdenv.isLinux) [
    latte-dock
    obs-studio
    vmware-workstation
  ]);
}
