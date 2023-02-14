{ pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    initExtra = ''
      autoload -U up-line-or-beginning-search
      autoload -U down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      bindkey "^[[A" up-line-or-beginning-search
      bindkey "^[[B" down-line-or-beginning-search
    '';
    localVariables.SPACESHIP_EXEC_TIME_PRECISION = 0;
    plugins = lib.singleton {
      name = "spaceship-prompt";
      src = pkgs.spaceship-prompt;
      file = "share/zsh/themes/spaceship.zsh-theme";
    };
  };
}
