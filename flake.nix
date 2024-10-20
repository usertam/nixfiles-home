{
  description = "usertam's home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-db.url = "github:usertam/nix-index-db/standalone/nixpkgs-unstable";
    nix-index-db.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: let
    forAllSystems = with nixpkgs.lib; genAttrs platforms.unix;
  in {
    packages = forAllSystems (system: rec {
      homeCommon = {
        username,
        graphical ? false,
      }: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {
          inherit inputs username graphical;
        };
        modules = [
          ./programs/home.nix
          ./programs/common.nix
          ./programs/broot.nix
          ./programs/btop.nix
          ./programs/direnv.nix
          ./programs/git.nix
          ./programs/nano.nix
          ./programs/nix.nix
          ./programs/nix-index-db.nix
          ./programs/ssh.nix
          ./programs/zsh.nix
        ] ++ nixpkgs.lib.optionals graphical [
          ./programs/fonts.nix
          ./programs/kitty.nix
          ./programs/vlc.nix
          ./programs/rbw.nix
          ./programs/vscodium.nix
        ];
      };
      homeConfigurations."tam" = homeCommon {
        username = "tam";
        graphical = true;
      };
      default = homeConfigurations."tam".activationPackage;
    });
  };
}
