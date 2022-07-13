{ ... }:

{
  programs.broot = {
    enable = true;
    enableBashIntegration = false;
    enableFishIntegration = false;
    enableZshIntegration = true;
  };
}
