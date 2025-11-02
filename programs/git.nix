{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    signing = {
      key = "EC4EE4903C8236982CABD2062D8760B0229E2560";
      signByDefault = true;
    };
    lfs.enable = true;
    settings = {
      user = {
        email = "code@usertam.dev";
        name = "usertam";
      };
      core = {
        editor = "nano";
        excludesfile = builtins.toFile "gitignore" ''
          .DS_Store
          .claude
        '';
        pager = "less -+X";
      };
      init.defaultBranch = "master";
      rerere.enabled = true;
    };
  };
}
