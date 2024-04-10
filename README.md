# nixfiles-home

A set of opinionated `home-manager` configurations in complement to [usertam/nixfiles](https://github.com/usertam/nixfiles), separately managed for good reasons.

## Clone home-manager configuration
```sh
git clone git@github.com:usertam/nixfiles-home.git
cd nixfiles-home
nix shell nixpkgs#home-manager
home-manager switch --flake .
```

## Update home-manager flake.lock
```sh
nix flake update --commit-lock-file
```

## License
This project is licensed under the MIT License. See [LICENSE](LICENSE) for more information.
