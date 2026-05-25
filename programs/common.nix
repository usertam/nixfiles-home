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
  # Force disable __noChroot in claude-code.
  claude-code' = pkgs.claude-code.overrideAttrs (prev: {
    __noChroot = false;
  });
in {
  # Allow unfree packages.
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
      "discord-canary"
      "slack"
      "vscode-extension-anthropic-claude-code"
    ];

  home.packages = with pkgs; [
    claude-code'
    coreutils
    curl
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
    llvmPackages_latest.clang
    llvmPackages_latest.libcxx
    llvmPackages_latest.lld
    nix-index
    nixfmt
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
    tailscale
    typst
  ];
}
