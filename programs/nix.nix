{ lib, pkgs, ... }:

{
  nix = {
    # Use bleeding-edge version of nix, patched with what-the-hack.
    package = (pkgs.nixVersions.nixComponents_2_29.appendPatches [
      (pkgs.fetchpatch {
        url = "https://github.com/NixOS/nix/compare/master...usertam:nix:0dab9b9f003d5354e2af2227464d5962c740f74f.patch";
        hash = "sha256-Xudx14849LHbvusVVN1J2PYwLLLE20Jt2OXiYKjlQdg=";
      })
    ]).nix-everything.overrideAttrs (prev: {
      doCheck = false;
      doInstallCheck = false;
    });

    # In case we have a diabolical system nix config.
    settings.extra-experimental-features = [ "nix-command" "flakes" ];

    # Lock nixpkgs in registry.
    registry.nixpkgs = {
      from = {
        type = "indirect";
        id = "nixpkgs";
      };
      to = let
        lock = lib.importJSON ../flake.lock;
      in {
        inherit (lock.nodes.nixpkgs.locked) rev;
        type = "github";
        owner = "nixos";
        repo = "nixpkgs";
      };
    };
  };
}
