{ pkgs, lib, graphical, ... }:

let
  # Change pixz default tar compress suffix to .tar.xz.
  # Let pixz provide /bin/xz.
  pixz' = pkgs.pixz.overrideAttrs (prev: {
    patchPhase = (prev.patchPhase or "") + ''
      substituteInPlace src/pixz.c \
        --replace 'SUF(WRITE, ".tar", ".tpxz");' 'SUF(WRITE, ".tar", ".tar.xz");'
    '';
    postInstall = (prev.postInstall or "") + ''
      ln -s $out/bin/pixz $out/bin/xz
    '';
  });
  # Let pigz provide /bin/gzip.
  pigz' = pkgs.symlinkJoin {
    name = "pigz";
    paths = [ pkgs.pigz ];
    postBuild = ''
      ln -s $out/bin/pigz $out/bin/gzip
    '';
  };
  # Let nmap provide /bin/nc and /bin/netcat.
  nmap' = pkgs.symlinkJoin {
    name = "nmap";
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
    file
    findutils
    fzf
    git
    gnugrep
    gnused
    gnutar
    htop
    jq
    less
    lesspipe
    llvmPackages_latest.clang
    llvmPackages_latest.libcxx
    llvmPackages_latest.lld
    nix-index
    nixos-rebuild
    nmap'
    openssh
    p7zip
    pigz'
    pixz'
    python3
    rsync
  ] ++ lib.optionals graphical [
    discord-canary
    ffmpeg
    gnupg
    graphicsmagick
    imagemagick
    mods
    poppler_utils
    qemu
    qrencode
    rclone
    socat
    sshfs
    tailscale
    typst
  ];
}
