{ pkgs, lib, ... }:

{
  # Allow unfree packages.
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  home.packages = with pkgs; [
    coreutils
    diffutils
    discord-canary
    file
    findutils
    git
    gnugrep
    gnupg
    gnused
    gnutar
    graphicsmagick
    home-manager
    htop
    imagemagick
    kitty.terminfo
    less
    lesspipe
    nano
    nix-index
    nixos-rebuild
    nmap
    openssh
    poppler_utils
    python3
    qrencode
    rclone
    rsync
    socat
  ];
}
