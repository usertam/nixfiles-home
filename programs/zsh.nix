{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    localVariables.SPACESHIP_EXEC_TIME_PRECISION = 0;
    plugins = [
      {
        name = "spaceship-prompt";
        src = pkgs.spaceship-prompt;
        file = "share/zsh/themes/spaceship.zsh-theme";
      }
    ];
  };
}
