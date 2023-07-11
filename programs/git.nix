{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userEmail = "heiyiutam@gmail.com";
    userName = "usertam";
    signing = {
      key = "A6C5AC43";
      signByDefault = true;
    };
    extraConfig.init.defaultBranch = "master";
    extraConfig.core.editor = "nano";
    extraConfig.core.excludesfile = builtins.toFile "gitignore" ".DS_Store\n";
    extraConfig.core.pager = "less -+X";
  };
}
