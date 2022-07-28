{ pkgs, nix-index-db, ... }:

{
  home.file.".cache/nix-index/files" = {
    source = nix-index-db.packages.${pkgs.system}.default;
  };
}
