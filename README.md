# Dotfiles

My configuration for the various tools I use.

~~**This README needs a thorough rewrite.**~~
~~**All instructions are out-of-date.**~~

I use [Sway](https://swaywm.org) (a tiling window manager running on Wayland)
on NixOS on both my laptop and my desktop.

I also have two macbooks for work (M1 and Intel).

This repository lives under `$HOME/dotfiles` and I use [Home Manager](https://github.com/rycee/home-manager)
to manage my configuration files and my packages.

I use Gnome Keyring to manage my secrets (SSH, GPG) and to have a graphical prompt
to unlock my keys.

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

- `./profiles`: configurations for my tools, desktop environment and other stuff.

  Most configurations work with NixOS and nix-darwin but some are exclusive to each
  platform.

  I am currently in the process of rewriting some of these configurations to be compatible
  with a standalone Home Manager installation.

- `./cachix`: this folder is owned by cachix and serves to configure substituers.

  Substituers are sources that will be used to lookup binary packages to minimise
  local rebuilds.

- `./secrets`: secrets managed with sops and [`sops-nix`](https://github.com/Mic92/sops-nix).

## Initial setup

1. Clone this repository.

    ``` console
    $ git clone https://github.com/berbiche/dotfiles
    $ cd dotfiles
    ```

    If you are already using Nix >= 2.4 and have `experimental-features = nix-command flakes`
    in your `/etc/nix/nix.conf`, then you won't need to do the next steps and
    can jump directly to building.

1. Enter the nix shell

    ``` console
    $ nix-shell
    ```

1. Build the system

  3.1. Build the system (in this case the `mero` host)

    ``` console
    $ rebuild switch --flake '.#mero' -v -L
    ```

## Building

If the new system configuration has been built once before, then you don't need to
use the nix-shell.

1. Rebuild the system

    - On NixOS (in this case the `mero` host)

        ``` console
        $ sudo nixos-rebuild switch --flake '.#mero' -v -L
        building the system configuration...
        ```

        This command is also aliased to the command `nrsf` in my ZSH shell.

    - On Darwin

        ``` console
        $ darwin-rebuild switch --flake '.#PC335' -v -L
        building the system configuration...
        ```

        Note this command **SHOULD NOT** be run with root with my configuration.

        `nix-darwin` will automatically request superuser permissions as required.

        This command is also aliased to the command `nrsf` in my ZSH shell.

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

## Adding a Cachix cache

``` console
$ cachix use <name> -d . -m nixos
```

The `-d` flag instructs cachix to use the current folder as the base folder instead of `/etc/nixos`
while the `-m` flag forces cachix to only create nix files under `./cachix` (and to update `./cachix.nix`).

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
- [fd](https://github.com/sharkdp/fd) (find with a much more intuitive syntax to me though I use them interchangeably)
- [neofetch](https://github.com/dylanaraps/neofetch) (get basic system information from the terminal)
- [starship](https://github.com/starship/starship) (cool shell prompt with git, nodejs, rust, go, etc. support)
- [hexyl](https://sharkdp/hexyl) (cli hex viewer, an alternative to xxd)

### TODOS

- Further improve the README, maybe change markdown to orgmode

- Transform my profiles in real Nix modules where it makes sense.

  Certain profiles will never be loaded on Darwin or NixOS because
  they do not expose certain options, resulting in an error.
