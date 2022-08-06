{ nix-index-bin, ... }:

{
  home.file.".cache/nix-index/files" = {
    source = nix-index-bin;
  };
}
