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
  # Enable HTTP/3 support in curl.
  curl' = pkgs.curl.override {
    http3Support = true;
  };
  # Hotfix a tailscale test on aarch64-darwin.
  tailscale' = pkgs.tailscale.overrideAttrs (prev: {
    doCheck = if pkgs.stdenv.hostPlatform.system == "aarch64-darwin" then false else prev.doCheck;
  });
in {
  # Allow unfree packages.
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
      "discord-canary"
      "slack"
    ];

  home.packages = with pkgs; [
    claude-code
    coreutils
    curl'
    diffutils
    file
    findutils
    fzf
    git
    gnugrep
    gnumake
    gnupatch
    gnused
    gnutar
    htop
    inetutils
    jq
    less
    lesspipe
    llvmPackages_20.clang
    llvmPackages_20.libcxx
    llvmPackages_20.lld
    nix-index
    nixfmt-rfc-style
    nmap'
    openssh
    p7zip
    pigz'
    pixz'
    podman
    podman-compose
    python3
    rsync
    tmux
    util-linux
  ] ++ lib.optionals graphical [
    discord-canary
    ffmpeg
    gnupg
    graphicsmagick
    imagemagick
    mods
    poppler-utils
    qemu
    qrencode
    rclone
    slack
    socat
    sshfs
    tailscale'
    typst
  ];
}
