{ pkgs, lib, ... }:

let
  nmap-with-nc-alias = pkgs.symlinkJoin {
    name = "nmap-with-nc-alias";
    paths = [ pkgs.nmap ];
    postBuild = ''
      ln -s $out/bin/ncat $out/bin/nc
      ln -s $out/bin/ncat $out/bin/netcat
    '';
  };
in {
  # Allow unfree packages.
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  home.packages = with pkgs; [
    coreutils
    diffutils
    discord-canary
    ffmpeg
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
    mods
    nix-index
    nixos-rebuild
    nmap-with-nc-alias
    openssh
    poppler_utils
    python3
    qrencode
    rclone
    rsync
    socat
    tailscale
  ];
}
