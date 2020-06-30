# Dotfiles

My configuration for the various tools I use.

I use [Sway](https://swaywm.org) (a tiling window manager running on Wayland) on NixOS on both my laptop and my desktop.

This repository lives under `$HOME/dotfiles` and I use [home-manager](https://github.com/rycee/home-manager) to manage
my configuration files and my packages.

I use Gnome Keyring to manage my secrets (SSH, GPG) and to have a graphical prompt to unlock my keys.

External dependencies are specified with [niv](https://github.com/nmattia/niv) in `niv/sources.json`.

**NOTE**  
The building process is more complicated than it should be because nix currently
lacks a declarative way to pin nixpkgs in the environment (instead of relying on the nixpkgs channel).

## Initial setup

1. Clone this repository.

    ``` console
    $ git clone https://github.com/berbiche/dotfiles
    $ cd dotfiles
    ```

2. Create an SSH keypair for your user to login as root locally.

3. Add your generated keypair's public key to the root account authorized_keys.

4. Start a local SSH server allowing root login with an SSH key

## Building

Building the system configuration is done using `nixops` because it allows a user to declaratively pin the nixpkgs version
used in the build.

1. Enter the nix-shell

    ``` console
    $ nix-shell
    [nix-shell] $ _
    ```

2. Create the deployment with nixops

    ``` console
    [nix-shell] $ nixops create deployment.nix -d $NAME_OF_THE_DEPLOYMENT
    ```

3. Deploy

    ``` console
    [nix-shell] $ nixops deploy -d $NAME_OF_THE_DEPLOYMENT --boot --dry-run
    ```

4. Reboot in the new system configuration

    ``` console
    $ shutdown -r now
    ```

## Updating

1. Update the dependencies:

    ``` console
    $ nix-shell
    [nix-shell]$ niv update
    Updating all packages
      Package: nixpkgs
      ...
    Done: Updating all packages
    ```

2. Then rebuild:

    ```console
    $ nix-shell
    [nix-shell]$ nixops deploy -d $NAME_OF_YOUR_DEPLOYMENT
    ```

## Configuration

Most programs configuration live under `user/home-manager/programs`.

### ZSH

Many aliases are defined in my ZSH config that replaces default commands.

- [exa](https://github.com/ogham/exa) (ls with --tree and other goodies)
- [bat](https://github.com/sharkdp/bat) (cat with syntax highlighting and pagination)
- [ripgrep](https://github.com/BurntSushi/ripgrep) (opiniated grep with defaults applied, claims to be faster than grep)
- [ripgrep-all](https://github.com/phiresky/ripgrep-all) (grep inside PDFs, E-Books, zip, etc.)
- [fd](https://github.com/sharkdp/fd) (find with a much more intuitive syntax to me though I use them interchangeably)
- [tldr](https://github.com/tldr-pages/tldr) (super simple manpage consisting of examples)
- [neofetch](https://github.com/dylanaraps/neofetch) (print system information to your terminal)
- [starship](https://github.com/starship/starship) (cool shell prompt with git, nodejs, rust, go, etc. support)
- [hexyl](https://sharkdp/hexyl) (cli hex viewer, an alternative to xxd)

