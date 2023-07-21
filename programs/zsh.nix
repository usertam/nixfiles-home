{ pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;

    # cherry-pick oh-my-zsh configs.
    initExtra = lib.concatMapStrings
      (a: "source ${pkgs.oh-my-zsh}/share/oh-my-zsh/lib/${a}.zsh;")
      [ "completion" "key-bindings" ] + ''
        setopt correct
      '' + ''
        # command-not-found handle.
        function command_not_found_handler() {
          # taken from http://www.linuxjournal.com/content/bash-command-not-found
          # - do not run when inside Midnight Commander or within a Pipe
          if [[ -n "''${MC_SID-}" ]] || ! [[ -t 1 ]]; then
            >&2 echo "zsh: $1: command not found"
            return 127
          fi

          # warn command not found and indicate ongoing dots.
          >&2 printf '\e[2m'
          >&2 printf "zsh: $1: command not found..."

          ATTR=$(${pkgs.nix-index}/bin/nix-locate \
            --top-level --minimal --at-root --whole-name "/bin/$1")
          COUNT=$(echo -n "$ATTR" | grep -c '^')

          # remove ongoing dots.
          >&2 printf '\b\b  \b\b\e[0m'

          case $COUNT in
            0)
              >&2 printf '\n'
              return 127;;
            *)
              if [ $COUNT -gt 1 ]; then
                ATTR="$(echo "$ATTR" | ${pkgs.fzy}/bin/fzy)"
              fi
              if [ -z "$ATTR" ]; then
                return 127
              fi
              >&2 printf '\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b'
              >&2 printf '\e[2m'
              >&2 printf 'prepend to path.  \n'
              >&2 printf '> nix shell nixpkgs#%s\e[0m\n' "''${ATTR%.out}"
              (trap : INT; nix shell "nixpkgs#$ATTR" -c $@; nix shell "nixpkgs#$ATTR")
              return;;
          esac
        }

        # alias for qrencode, imagemagick and kitty +kitten icat.
        function qrcode() {
          printf '\n'; ${pkgs.qrencode}/bin/qrencode "''${1:-https://github.com/usertam}" -o- | \
            ${pkgs.imagemagick}/bin/convert -scale "''${2:-200%}" png:- png:-  | \
            ${pkgs.kitty}/bin/kitty +kitten icat
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
