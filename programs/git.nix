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
