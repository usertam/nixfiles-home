{ pkgs, inputs, ... }:

{
  home.file.".cache/nix-index/files" = {
    source = inputs.nix-index-db.packages.${pkgs.system}.default;
  };
}
