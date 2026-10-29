{ pkgs, ... }:

{
  programs.btop = {
    enable = true;
    package = pkgs.btop.overrideAttrs (prev: {
      patches = (prev.patches or [ ]) ++ [
        (pkgs.fetchpatch {
          name = "remove-terminal-size-limit.patch";
          url = "https://github.com/usertam/btop/commit/85c1c7568ab08818526f85057919a04c2d6e5dd1.patch";
          hash = "sha256-q6SjePiygFv/cYqzniOM5MZPkmMvAZ1B5aEW0wWSQos=";
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
