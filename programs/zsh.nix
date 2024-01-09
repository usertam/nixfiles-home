{ pkgs, lib, ... }:

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

      function nixfiles-commit() {
        ( 
          set -e
          cd ~/Desktop/projects/nixfiles
          git switch nixos-lock
          git switch nixos
          if [ -z "$(git diff --cached)" ]; then
            git add .
          fi
          git commit
          git switch -
          if [ -n "$(git status --porcelain)" ]; then
            git stash
            git rebase -
            git stash pop
          else
            git rebase -
          fi
        )
      }

      function home-manager-commit() {
        ( 
          set -e
          cd ~/Desktop/projects/nixfiles-home
          git switch home-manager-lock
          git switch home-manager
          if [ -z "$(git diff --cached)" ]; then
            git add .
          fi
          git commit
          git switch -
          if [ -n "$(git status --porcelain)" ]; then
            git stash
            git rebase -
            git stash pop
          else
            git rebase -
          fi
        )
      }

      # Alias for qrencode, graphicsmagick and kitty +kitten icat.
      function qrcode() {
        printf '\n'; ${pkgs.qrencode}/bin/qrencode "''${1:=https://github.com/usertam}" -o- | \
          ${pkgs.graphicsmagick}/bin/gm convert -scale "''${2:-200%}" png:- png:-  | \
          ${pkgs.kitty}/bin/kitty +kitten icat
        local COL=$(stty size | cut -d\  -f2)
        if [ ''${#1} -gt $((COL/2)) ]; then
          1="''${1:0:$((COL/4))}...''${1:$((''${#1}-COL/4)):''${#1}}"
        fi
        printf '\n'
        printf '%*s' $((($COL-''${#1})/2))
        echo "$1"
      }
    '';

    # enable spaceship theme.
    plugins = lib.singleton {
      name = "spaceship-prompt";
      src = pkgs.spaceship-prompt;
      file = "share/zsh/themes/spaceship.zsh-theme";
    };

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
