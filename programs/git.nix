{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userEmail = "code@usertam.dev";
    userName = "usertam";
    signing = {
      key = "EC4EE4903C8236982CABD2062D8760B0229E2560";
      signByDefault = true;
    };
    lfs.enable = true;
    extraConfig = {
      core = {
        editor = "nano";
        excludesfile = builtins.toFile "gitignore" ".DS_Store\n";
        pager = "less -+X";
      };
      init.defaultBranch = "master";
      rerere.enabled = true;
    };
  };
}
