{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      forwardAgent = true;
      controlMaster = "auto";
      controlPersist = "15m";
      identityFile = [
        "~/.ssh/id/self"
        "~/.ssh/id/git"
      ];
    };
  };
}
