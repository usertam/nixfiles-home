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

      # Enable zsh corrections and history share.
      setopt correct
      setopt share_history

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

        local ATTR=$(${pkgs.nix-index}/bin/nix-locate --minimal --at-root --whole-name "/bin/$1")
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

      # Spawns a nix-shell with specified python packages.
      function python-with() {
        nix-shell -p 'with builtins.getFlake "nixpkgs"; with legacyPackages.${pkgs.system}; python3.withPackages (p: with p; [ '"$*"' ])'
      }
    '';

    plugins = [
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

    # Let less quit if one screen, ignore case in searches if lowercase,
    # and output color control characters.
    sessionVariables.LESS = "-FiR";

    # Enable lesspipe.
    sessionVariables.LESSOPEN = "|${pkgs.lesspipe}/bin/lesspipe.sh %s";

    # Turn off direnv log.
    sessionVariables.DIRENV_LOG_FORMAT = "";

    # Fix compiler-invoking-linker problems like "ld: library not found for -liconv".
    sessionVariables.LIBRARY_PATH = lib.makeLibraryPath (
      [ pkgs.libiconv ]
      ++ lib.optionals pkgs.stdenv.isDarwin [
        pkgs.darwin.libresolv
      ]
    );

    # Ignore stupid autocorrect suggestions.
    localVariables.CORRECT_IGNORE = "[_|.]*";

    # Enable color output.
    shellAliases = (builtins.listToAttrs
      (map (attr: { name = attr; value = "${attr} --color=auto"; })
        [ "diff" "grep" "ls" ]));
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      character = {
        success_symbol = "[%](blue)";
        error_symbol = "[%](red)";
      };
      nix_shell = {
        disabled = true;
      };
      git_status = {
        format = "([\\[$ahead_behind$all_status\\]]($style) )";
        # Use regular non-dotted symbols, rendering is screwy.
        ahead = "↑";
        behind = "↓";
        diverged = "↕";
      };

      custom.nix_path_pkgs = let
        nix_path_pkgs = pkgs.rustPlatform.buildRustPackage {
          pname = "nix-path-pkgs";
          version = "0.1.0-unstable-2025-10-20";
          src = pkgs.fetchFromGitHub {
            owner = "usertam";
            repo = "nix-path-pkgs";
            rev = "bd592fe6b94a1c4572a72d69974e293a81cc0cc1";
            hash = "sha256-y+w635Y8Xoxuz8ss83O0H7jdSlEoT+fsPKVzEDRfxNQ=";
          };
          cargoHash = "sha256-iFHPy0vFBPrHTeMWo0Erx/7RJ9/5L700jHubKcNHatA=";
          meta.mainProgram = "nix-path-pkgs";
        };
      in {
        command = lib.getExe nix_path_pkgs;
        when = lib.getExe nix_path_pkgs;
        symbol = "❄️ ";
        style = "bold blue";
        format = "via [$symbol($output)]($style) ";
      };
    };
  };
}
