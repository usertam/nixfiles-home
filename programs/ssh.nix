{ ... }:

{
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    hashKnownHosts = true;
    matchBlocks = {
      "github" = {
        host = "github.com";
        identityFile = "~/.ssh/id/git";
      };
      "default" = {
        host = "*";
        identityFile = "~/.ssh/id/self";
      };
    };
  };
}
