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
    graphicsmagick
    home-manager
    htop
    imagemagick
    kitty.terminfo
    lesspipe
    nano
    nix-index
    nixos-rebuild
    openssh
    poppler_utils
    python3
    qrencode
    rclone
    rsync
  ];
}
