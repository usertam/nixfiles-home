{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;

    initExtra = ''
      # Cherry-pick some oh-my-zsh scripts.
      source ${pkgs.oh-my-zsh}/share/oh-my-zsh/lib/completion.zsh
      source ${pkgs.oh-my-zsh}/share/oh-my-zsh/lib/key-bindings.zsh

      # Enable zsh corrections.
      setopt correct

      # Custom nix-index command-not-found handle.
      function command_not_found_handler() {
        # taken from http://www.linuxjournal.com/content/bash-command-not-found
        # - do not run when inside Midnight Commander or within a Pipe
        if [[ -n "''${MC_SID-}" ]] || ! [[ -t 1 ]]; then
          >&2 printf 'zsh: %s: command not found' "$1"
          return 127
        fi

        # warn command not found and indicate ongoing dots.
        >&2 printf '\e[2m'
        >&2 printf 'zsh: %s: command not found...' "$1"
        local BACK=$(printf 'zsh: %s: command not found...' "$1" | wc -c)

        local ATTR=$(${pkgs.nix-index}/bin/nix-locate \
          --top-level --minimal --at-root --whole-name "/bin/$1")
        local COUNT=$(echo -n "$ATTR" | grep -c '^')

        if [ $COUNT -eq 0 ]; then
          # remove ongoing dots. ("..." -> ".")
          >&2 printf '\b\b  \b\b\e[0m\n'
          return 127
        fi

        # wipe the whole line.
        >&2 printf '\b \b%.0s' {1..$BACK}
        >&2 printf 'zsh: %s: conjuring up nix shell...\n' "$1"

        if [ $COUNT -gt 1 ]; then
          # select candidates, auto-fill the first result as prompt
          PROMPT="$(echo "$ATTR" | ${pkgs.fzy}/bin/fzy -e "$1" | head -1 | cut -d. -f1)"
          ATTR="$(echo "$ATTR" | ${pkgs.fzy}/bin/fzy -p '> nix shell nixpkgs#' -q "$PROMPT")"
          if [ -z "$ATTR" ]; then return 127; fi
          >&2 printf '\e[2m'
        fi

        >&2 printf '> nix shell nixpkgs#%s\e[0m\n' "''${ATTR%.out}"
        (trap : INT; nix shell "nixpkgs#$ATTR" -c $@; nix shell "nixpkgs#$ATTR")
        return
      }

      # Alias for qrencode, graphicsmagick and kitty +kitten icat.
      function qrcode() {
        if [ -z "$1" ]; then 1=$(cat /dev/stdin); fi
        printf '\n'; ${pkgs.qrencode}/bin/qrencode "''${1:=https://github.com/usertam}" -o- | \
          ${pkgs.graphicsmagick}/bin/gm convert -scale "''${2:-200%}" png:- png:-  | \
          ${pkgs.kitty}/bin/kitty +kitten icat
        local COL=$(tput cols)
        if [ ''${#1} -gt $((COL/2)) ]; then
          1="''${1:0:$((COL/4))}...''${1:$((''${#1}-COL/4)):''${#1}}"
        fi
        printf '\n'
        printf '%*s' $((($COL-''${#1})/2))
        printf '%q\n' "$1"
      }
    '';

    plugins = [
      {
        # Enable spaceship theme.
        name = "spaceship-prompt";
        src = pkgs.spaceship-prompt;
        file = "share/zsh/themes/spaceship.zsh-theme";
      }
      {
        # Enable zsh-histdb, alternative shell history in sqlite.
        name = "zsh-histdb";
        src = pkgs.stdenvNoCC.mkDerivation rec {
          pname = "zsh-histdb";
          version = "30797f0";
          src = pkgs.fetchFromGitHub {
            owner = "larkery";
            repo = pname;
            rev = "30797f0c50c31c8d8de32386970c5d480e5ab35d";
            sha256 = "sha256-PQIFF8kz+baqmZWiSr+wc4EleZ/KD8Y+lxW2NT35/bg=";
          };
          strictDeps = true;
          dontUnpack = true;
          dontBuild = true;
          installPhase = ''
            mkdir -p $out/lib/${pname}
            cp -r $src/* $out/lib/${pname}
          '';
        };
        file = "lib/zsh-histdb/sqlite-history.zsh";
      }
    ];

    # enable less scrolling.
    sessionVariables.LESS = "-R";

    # turn off spaceship exec time decimals.
    localVariables.SPACESHIP_EXEC_TIME_PRECISION = 0;

    # ignore stupid autocorrect suggestions.
    localVariables.CORRECT_IGNORE = "[_|.]*";

    # enable color output.
    shellAliases = (builtins.listToAttrs
      (map (attr: { name = attr; value = "${attr} --color=auto"; })
        [ "diff" "grep" "ls" ]))
    // {
      qrcode = "noglob qrcode";
    };
  };
}
