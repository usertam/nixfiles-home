{ pkgs, lib, ... }:

{
  # Allow unfree packages.
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  home.packages = with pkgs; [
    axel
    clang
    ccache
    coreutils
    diffutils
    discord-canary
    findutils
    gnugrep
    gnupg
    gnused
    graphicsmagick
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
    qrencode
    rclone
    rsync
  ];
}
