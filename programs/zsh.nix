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
        # alias for qrencode, imagemagick and kitty +kitten icat.
        function qrcode() {
          printf '\n'; ${pkgs.qrencode}/bin/qrencode "''${1:-https://github.com/usertam}" -o- | \
            ${pkgs.imagemagick}/bin/convert -scale "''${2:-400%}" png:- png:-  | \
            ${pkgs.kitty}/bin/kitty +kitten icat
        }
      '';

    # enable spaceship theme.
    plugins = lib.singleton {
      name = "spaceship-prompt";
      src = pkgs.spaceship-prompt;
      file = "share/zsh/themes/spaceship.zsh-theme";
    };

    # turn off spaceship exec time decimals.
    localVariables.SPACESHIP_EXEC_TIME_PRECISION = 0;

    # enable color output.
    shellAliases = builtins.listToAttrs
      (map (attr: { name = attr; value = "${attr} --color=auto"; })
        [ "diff" "grep" "ls" ]);
  };
}
