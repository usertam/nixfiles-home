# nixfiles-home

A set of opinionated `home-manager` configurations in complement to [usertam/nixfiles](https://github.com/usertam/nixfiles), separately managed for good reasons.

## Clone configuration
```sh
git clone git@github.com:usertam/nixfiles-home.git
cd nixfiles-home
```

## Build and activate configuration
Use `home-manager`, or manually build and activate with `nix`.
```
nix shell nixpkgs#home-manager
home-manager switch --flake .
```
```
nix build .#homeConfigurations.tam.activationPackage
result/activate
```

## Update flake.lock
```sh
nix flake update --commit-lock-file
```

## License
This project is licensed under the MIT License. See [LICENSE](LICENSE) for more information.
