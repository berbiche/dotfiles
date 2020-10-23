# Dotfiles

My configuration for the various tools I use.

**This README needs a thorough rewrite.**
**All instructions are out-of-date.**

I use [Sway](https://swaywm.org) (a tiling window manager running on Wayland) on NixOS on both my laptop and my desktop.

This repository lives under `$HOME/dotfiles` and I use [home-manager](https://github.com/rycee/home-manager) to manage
my configuration files and my packages.

I use Gnome Keyring to manage my secrets (SSH, GPG) and to have a graphical prompt to unlock my keys.

## Initial setup

1. Clone this repository.

    ``` console
    $ git clone https://github.com/berbiche/dotfiles
    $ cd dotfiles
    ```

If you are already using Nix >= 2.4 and have `experimental-features = nix-command flakes` in your `/etc/nix/nix.conf`,
then you won't need to do the next steps and can jump directly to building.

2. Enter the nix shell

    ``` console
    $ nix-shell
    ```

3. Build the system (in this case the `merovingian` host)

    ``` console
    $ rebuild switch --flake '.#merovingian' -v
    ```

## Building

If the new system configuration has been built once before, then you don't need to use the nix-shell

1. Rebuild the system (in this case the `merovingian` host)

    ``` console
    $ sudo nixos-rebuild switch --flake '.#merovingian' -v
    ```

## Updating

1. Update the dependencies

    ``` console
    $ nix flake update --recreate-lock-file
    ```

2. Rebuild (in this case the `merovingian` host)

    ``` console
    $ sudo nixos-rebuild switch --flake . -v
    ```

## Add a Cachix cache

``` console
$ cachix use <name> -d . -m nixos
```

The `-d` flag makes cachix operate on the current directory for its `cachix.nix` and `/cachix` folder
while the `-m` flag forces cachix to only modify the two files mentionned before.

## Darwin

Until nix-darwin is updated to have proper support for Flakes, the installation has to be done
manually (or via a script).

1. Build the configuration

    ``` console
    $ nix build '.#darwinConfigurations.${machine-name}' -v
    ```

2. Activate the system configuration

    ``` console
    $ sudo ./result/activate
    ```

3. Activate the user configuration

    ``` console
    $ ./result/activate-user
    ```

The configuration is now active and linked.
You can purge your old configurations at anytime with `sudo nix-collect-garbage -d`.

## Configuration

Most programs configuration live under `user/programs`.

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

### TODOS

Packages to add to my configuration:

- <https://github.com/jtheoff/swappy> blocked by <https://github.com/NixOS/nixpkgs/pull/81116>
