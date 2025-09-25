{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;

    # Save 1 billion history entries.
    history.size = 1000000000;
    history.save = 1000000000;

    initContent = ''
      # Cherry-pick some oh-my-zsh scripts.
      source ${pkgs.oh-my-zsh}/share/oh-my-zsh/lib/completion.zsh
      source ${pkgs.oh-my-zsh}/share/oh-my-zsh/lib/key-bindings.zsh

      # Additional key bindings.
      bindkey '^[[46;9u' insert-last-word

      # Enable zsh corrections.
      setopt correct

      # Enable zsh history share.
      setopt share_history

      # Manually load kitty shell-integration. Fix the cursor underline issue.
      autoload -Uz -- ${
        pkgs.runCommand "kitty-integration" { src = pkgs.kitty; } ''
          mkdir -p $out
          substitute $(find $src -name kitty-integration) $out/kitty-integration \
            --replace-fail '(( ! opt[(Ie)no-cursor] ))' 'false'
        ''
      }/kitty-integration
      kitty-integration
      unfunction kitty-integration

      # Load homebrew shell integration.
      if [ -d "/opt/homebrew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi

      # Custom nix-index command-not-found handle.
      function command_not_found_handler() {
        # Do not run when stdin or stdout not opened on a terminal.
        # Do not run when the process is in background.
        if ! [ -t 0 ] || ! [ -t 1 ] || ps -o stat= -p $$ | grep -q '+'; then
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
          buildInputs = with pkgs; (prev.buildInputs or []) ++ [ gnugrep gnused ];
          patches = (prev.patches or []) ++ lib.singleton (pkgs.writeText "customize-for-new-nix-shell.patch" ''
            diff --git a/sections/nix_shell.zsh b/sections/nix_shell.zsh
            index 3d35db052..77cdfccfe 100644
            --- a/sections/nix_shell.zsh
            +++ b/sections/nix_shell.zsh
            @@ -10,10 +10,11 @@
             
             SPACESHIP_NIX_SHELL_SHOW="''${SPACESHIP_NIX_SHELL_SHOW=true}"
             SPACESHIP_NIX_SHELL_ASYNC="''${SPACESHIP_NIX_SHELL_ASYNC=false}"
            +SPACESHIP_NIX_SHELL_VERSION="''${SPACESHIP_NIX_SHELL_VERSION=false}"
             SPACESHIP_NIX_SHELL_PREFIX="''${SPACESHIP_NIX_SHELL_PREFIX="$SPACESHIP_PROMPT_DEFAULT_PREFIX"}"
             SPACESHIP_NIX_SHELL_SUFFIX="''${SPACESHIP_NIX_SHELL_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"
             SPACESHIP_NIX_SHELL_SYMBOL="''${SPACESHIP_NIX_SHELL_SYMBOL="❄ "}"
            -SPACESHIP_NIX_SHELL_COLOR="''${SPACESHIP_NIX_SHELL_COLOR="yellow"}"
            +SPACESHIP_NIX_SHELL_COLOR="''${SPACESHIP_NIX_SHELL_COLOR="blue"}"
             
             # ------------------------------------------------------------------------------
             # Section
            @@ -23,12 +24,12 @@ SPACESHIP_NIX_SHELL_COLOR="''${SPACESHIP_NIX_SHELL_COLOR="yellow"}"
             spaceship_nix_shell() {
               [[ $SPACESHIP_NIX_SHELL_SHOW == false ]] && return
             
            -  [[ -z "$IN_NIX_SHELL" ]] && return
            +  [[ -z "$IN_NIX_SHELL" ]] && ! (echo "$PATH" | grep -q '/nix/store') && return
             
            -  if [[ -z "$name" || "$name" == "" ]] then
            -    display_text="$IN_NIX_SHELL"
            +  if [[ $SPACESHIP_NIX_SHELL_VERSION == true ]]; then
            +    display_text="$(echo "$PATH" | ${pkgs.gnugrep}/bin/grep -Po '/nix/store.*?/bin' | uniq | ${pkgs.gnused}/bin/sed ':a; s+/.\{42\}-++g; s+/bin++g; s/\n/, /g; N; ba;')"
               else
            -    display_text="$IN_NIX_SHELL ($name)"
            +    display_text="$(echo "$PATH" | ${pkgs.gnugrep}/bin/grep -Po '/nix/store.*?/bin' | uniq | ${pkgs.gnused}/bin/sed ':a; s+/.\{42\}-++g; s+/bin++g; s/-[0-9][0-9.]*//g; s/\n/, /g; N; ba;')"
               fi
             
               # Show prompt section
            '');
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

    # Fix compiler-invoking-linker problems like "ld: library not found for -liconv".
    localVariables.LIBRARY_PATH =
      let
        compLibs = [ pkgs.libiconv ] ++ lib.optionals pkgs.stdenv.isDarwin [ pkgs.darwin.libresolv ];
      in
      lib.makeLibraryPath compLibs;

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
      "clr" = "printf '\033[2J\033[3J\033[1;1H'";
      "qrcode" = "noglob qrcode";
    };
  };
}
