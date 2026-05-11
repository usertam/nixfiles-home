{ pkgs, ... }:

{
  programs.btop = {
    enable = true;
    package = pkgs.btop.overrideAttrs (prev: {
      patches = (prev.patches or []) ++ [
        (pkgs.fetchpatch {
          name = "remove-terminal-size-limit.patch";
          url = "https://github.com/usertam/btop/commit/4d9671f905881ade6c3a0e9a8118c663fc941e83.patch";
          hash = "sha256-riq+nNllVCHapqTRPt8ict8UNg8o+Z0Ik2iaW6lHwmM=";
        })
        (pkgs.fetchpatch {
          name = "change-default-theme-background-to-false.patch";
          url = "https://github.com/usertam/btop/commit/e37aa387c6702cdf6ece63fadda65e61262f9f9b.patch";
          hash = "sha256-9bpcwZXW/+Tz7tq5XjbDNrKQEkUG4hhb+CMsP+/Ny9E=";
        })
      ];
    });
  };
}
