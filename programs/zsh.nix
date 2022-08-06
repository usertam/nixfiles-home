{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    initExtra = "compinit"; # workaround
    oh-my-zsh = {
      enable = true;
      plugins = [ "command-not-found" "git" ];
    };
    plugins = [
      {
        name = "spaceship-prompt";
        src = pkgs.spaceship-prompt;
        file = "share/zsh/themes/spaceship.zsh-theme";
      }
    ];
  };
}
