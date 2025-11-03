{ pkgs, inputs, ... }:

{
  home.file.".cache/nix-index/files" = {
    source = inputs.nix-index-db.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}
