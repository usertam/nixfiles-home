{ pkgs, ... }:

{
  programs.btop = {
    enable = true;
    package = pkgs.btop.overrideAttrs (prev: {
      patches = (prev.patches or [ ]) ++ [
        (pkgs.fetchpatch {
          name = "remove-terminal-size-limit.patch";
          url = "https://github.com/usertam/btop/commit/4d9671f905881ade6c3a0e9a8118c663fc941e83.patch";
          hash = "sha256-riq+nNllVCHapqTRPt8ict8UNg8o+Z0Ik2iaW6lHwmM=";
        })
      ];
      postPatch = (prev.postPatch or "") + ''
        substituteInPlace src/btop_config.cpp \
          --replace-fail '{"theme_background", true},' '{"theme_background", false},' \
          --replace-fail '{"proc_per_core", false},' '{"proc_per_core", true},'
      '';
    });
  };
}
