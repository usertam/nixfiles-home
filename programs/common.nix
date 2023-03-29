{ pkgs, lib, ... }:

{
  # Allow unfree packages.
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  home.packages = with pkgs; [
    axel
    clang
    ccache
    coreutils
    discord-canary
    findutils
    gnugrep
    gnupg
    gnused
    home-manager
    imagemagick
    lesspipe
    nano
    nix-index
    openssh
    podman-compose
    podman-tui
    poppler_utils
    python3
    rclone
    rsync
  ];
}
