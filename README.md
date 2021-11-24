# Dotfiles

My configuration for the various tools I use.

**This README needs a thorough rewrite.**
**All instructions are out-of-date.**

I use [Sway](https://swaywm.org) (a tiling window manager running on Wayland) on NixOS on both my laptop and my desktop.

This repository lives under `$HOME/dotfiles` and I use [home-manager](https://github.com/rycee/home-manager) to manage
my configuration files and my packages.

I use Gnome Keyring to manage my secrets (SSH, GPG) and to have a graphical prompt to unlock my keys.

## Structure

My configuration is organized as follows:

- `./flake.nix`: contains my system definitions

- `./top-level`: contains logic to load my custom NixOS/Darwin/Home Manager modules
  and the basic common setup used by all my systems.

  This is where some of the options that I use in my configuration are defined.

- `./user`: declares an active user, note that my system configuration does not
  support using multiple users yet.

- `./host`: this is where I define each host

- `./modules`: this is where I define my custom modules.

   These modules are loaded automatically depending on the platform
   by `./top-level/module.nix`

- `./cachix`: this folder is owned by cachix and serves to fetch binary files from
  trusted sources without having to build packages (substituers).

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
    $ rebuild switch --flake '.#merovingian' -v -L
    ```

## Building

If the new system configuration has been built once before, then you don't need to use the nix-shell

1. Rebuild the system

    - On NixOS (in this case the `merovingian` host)

        ``` console
        $ sudo nixos-rebuild switch --flake '.#merovingian' -v -L
        buulding the system configuration...
        ```

        This is also aliased to the command `nrsf` in my shells.

    - On Darwin

        ``` console
        $ sudo darwin-rebuild switch --flake '.#PC335' -v -L
        building the system configuration...
        ```

## Updating

1. Update the dependencies

    ``` console
    $ nix flake update
    ```

    or

    ``` console
    $ nix flake lock --update-input <input-name>
    ```

2. Rebuild per instructions in the [Building](#building) section

## Add a Cachix cache

``` console
$ cachix use <name> -d . -m nixos
```

The `-d` flag makes cachix operate on the current directory for its `cachix.nix` and `/cachix` folder
while the `-m` flag forces cachix to only modify the two files mentionned before.

## Darwin

As it stands, bootstrapping the system using only flakes is not possible
because nix-darwin does not expose the installer script in the flake.

1. Build the configuration

    ``` console
    $ nix build '.#darwinConfigurations.${machine-name}' -v -L
    ...
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

### Email

1. Create an application password on Google

2. Copy the password and add it to the keyring

    ``` console
    $ nix shell nixpkgs#gnome3.libsecret
    $ secret-tool store --label='Gmail account for neomutt' account gmail
    Password: <paste>
    $ mbsync -V gmail
    ```

### Sops

Setup:

1. `sudo nix run nixpkgs#ssh-to-pgp -- -i /etc/ssh/ssh_host_rsa_key -o secrets/hosts/"$(hostname -s)".asc`
2. Copy the fingerprint to `.sops.yaml`

### pam_u2f

1. `pamu2fcfg -i pam://$(hostname -s) -o pam://$(hostname -s) >~/.config/Yubico/u2f_keys`

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

- Further improve the README, maybe change markdown to orgmode

- Transform my profiles in real Nix modules where it makes sense.

  Certain profiles will never be loaded on Darwin or NixOS because
  they do not expose certain options, resulting in an error.
