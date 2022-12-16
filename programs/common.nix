{ pkgs, lib, desktop, ... }:

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
  ] ++ (lib.optionals desktop [
    discord-canary
    streamlink
  ]) ++ (lib.optionals (desktop && pkgs.stdenv.isLinux) [
    latte-dock
    obs-studio
    vmware-workstation
  ]);
}
