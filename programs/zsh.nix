{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;

    initExtra = ''
      # Cherry-pick some oh-my-zsh scripts.
      source ${pkgs.oh-my-zsh}/share/oh-my-zsh/lib/completion.zsh
      source ${pkgs.oh-my-zsh}/share/oh-my-zsh/lib/key-bindings.zsh

      # Additional key bindings.
      bindkey '^[[46;9u' insert-last-word

      # Enable zsh corrections.
      setopt correct

      # Enable zsh history share.
      setopt share_history

      # Custom nix-index command-not-found handle.
      function command_not_found_handler() {
        # Do not run in non-interactive shell.
        if ! [ -t 1 ]; then
          >&2 printf 'zsh: %s: command not found' "$1"
          return 127
        fi

        # Warn command not found, indicate progress.
        >&2 printf '\e[2m'
        >&2 printf 'zsh: %s: command not found...' "$1"

        local ATTR=$(${pkgs.nix-index}/bin/nix-locate \
          --top-level --minimal --at-root --whole-name "/bin/$1")
        local COUNT=$(echo -n "$ATTR" | grep -c '^')

        if [ $COUNT -eq 0 ]; then
          # No candidates found, remove the extra dots.
          >&2 printf '\b\b  \b\b\e[0m\n'
          return 127
        fi

        # Wipe the line, char by char.
        local BACK=$(printf 'zsh: %s: command not found...' "$1" | wc -c)
        >&2 printf '\b \b%.0s' {1..$BACK}
        >&2 printf 'zsh: %s: conjuring up nix shell...\n' "$1"

        if [ $COUNT -gt 1 ]; then
          # Let user select candidates; auto-fill the first result as prompt.
          PROMPT="$(echo "$ATTR" | fzf -f "$1" | head -1 | cut -d. -f1)"
          ATTR="$(echo "$ATTR" | fzf --reverse --height 40% --prompt '> nix shell nixpkgs#' -q "$PROMPT")"
          if [ -z "$ATTR" ]; then return 127; fi
          >&2 printf '\e[2m'
        fi

        # Print and record the nix shell command.
        >&2 printf '> nix shell nixpkgs#%s\e[0m\n' "''${ATTR%.out}"
        print -s nix shell nixpkgs#''${ATTR%.out}; fc -A

        # Create a init file and run nix shell.
        local ZDOTDIR=$(mktemp -d)
        echo "TRAPEXIT() { rm -rf $ZDOTDIR }; [ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"; $@" > $ZDOTDIR/.zshenv
        ZDOTDIR=$ZDOTDIR nix shell "nixpkgs#$ATTR"

        # Report and return subshell exit status.
        STATUS=$?
        if [ $STATUS -ne 0 ]; then
          >&2 printf '\e[2mzsh: %s: nix shell exited with status code %d.\e[0m\n' "$1" $STATUS
        fi
        return $STATUS
      }

      # Spawns an impure bash->zsh nix-shell with specified python packages.
      function python-with() {
        nix-shell -p "with (builtins.getFlake \"nixpkgs\").legacyPackages.\''${pkgs.system}; python3.withPackages (p: with p; [ $* ])" --command "$SHELL"
      }

      # Alias for qrencode, graphicsmagick and kitty +kitten icat.
      function qrcode() {
        if [ -z "$1" ]; then 1=$(cat /dev/stdin); fi
        printf '\n'; ${pkgs.qrencode}/bin/qrencode "''${1:=https://github.com/usertam}" -o- | \
          ${pkgs.graphicsmagick}/bin/gm convert -scale "''${2:-200%}" png:- png:-  | \
          ${config.programs.kitty.package}/bin/kitty +kitten icat
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
        src = pkgs.spaceship-prompt.overrideAttrs (prev: {
          patches = (prev.patches or []) ++ lib.singleton (pkgs.fetchpatch {
            name = "customize-for-new-nix-shell.patch";
            url = "https://github.com/usertam/spaceship-prompt/commit/5b82eb25ad87a6c0b62c0681794bd0332b285f7e.patch";
            hash = "sha256-eZYw2J652iZZYvTMAAJqnTYb7PO4xuCcR4LTHLB3FeM=";
          });
        });
        file = "share/zsh/themes/spaceship.zsh-theme";
      }
      {
        # Enable zsh-histdb, alternative shell history in sqlite.
        name = "zsh-histdb";
        src = pkgs.stdenvNoCC.mkDerivation (final: {
          pname = "zsh-histdb";
          version = "30797f0";
          src = pkgs.fetchFromGitHub {
            owner = "larkery";
            repo = final.pname;
            rev = "30797f0c50c31c8d8de32386970c5d480e5ab35d";
            sha256 = "sha256-PQIFF8kz+baqmZWiSr+wc4EleZ/KD8Y+lxW2NT35/bg=";
          };
          strictDeps = true;
          dontUnpack = true;
          dontBuild = true;
          installPhase = ''
            mkdir -p $out/lib/${final.pname}
            cp -r $src/* $out/lib/${final.pname}
          '';
        });
        file = "lib/zsh-histdb/sqlite-history.zsh";
      }
    ];

    # Enable less scrolling.
    sessionVariables.LESS = "-R";

    # Enable lesspipe.
    sessionVariables.LESSOPEN = "|${pkgs.lesspipe}/bin/lesspipe.sh %s";

    # Turn off direnv log.
    sessionVariables.DIRENV_LOG_FORMAT = "";

    # Turn off spaceship exec time decimals.
    localVariables.SPACESHIP_EXEC_TIME_PRECISION = 0;

    # Ignore stupid autocorrect suggestions.
    localVariables.CORRECT_IGNORE = "[_|.]*";

    # Enable color output.
    shellAliases = (builtins.listToAttrs
      (map (attr: { name = attr; value = "${attr} --color=auto"; })
        [ "diff" "grep" "ls" ]))
    // {
      "cd?" = "cd $(find * -maxdepth 3 -type d ! -path '*.*' -print 2>/dev/null | fzf --reverse --height 40% --scheme=path)";
      "qrcode" = "noglob qrcode";
    };
  };
}
