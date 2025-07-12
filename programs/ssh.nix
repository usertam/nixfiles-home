{ ... }:

{
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    hashKnownHosts = true;
    controlMaster = "auto";
    controlPersist = "15m";
  };
}
