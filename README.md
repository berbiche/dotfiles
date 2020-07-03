# Dotfiles

My configuration for the various tools I use.

I use [Sway](https://swaywm.org) (a tiling window manager running on Wayland) on NixOS on both my laptop and my desktop.

This repository lives under `$HOME/dotfiles` and I use [home-manager](https://github.com/rycee/home-manager) to manage
my configuration files and my packages.

I use Gnome Keyring to manage my secrets (SSH, GPG) and to have a graphical prompt to unlock my keys.

External dependencies are specified with [niv](https://github.com/nmattia/niv) in `niv/sources.json`.

**NOTE**  
The building process is more complicated than it should be because I haven't found a way to
declarative pin nixpkgs in the environment (instead of relying on the nixpkgs channel).

## Initial setup

1. Clone this repository.

    ``` console
    $ git clone https://github.com/berbiche/dotfiles
    $ cd dotfiles
    ```

2. Create an SSH keypair for your user to login as root locally.

3. Add your generated keypair's public key to the root account `authorized_keys`.  
    The public key can be added to `/etc/ssh/authorized_keys.d/root` for instance.

4. Start a local SSH server allowing root login with an SSH key

## Building

Building the system configuration is done using `nixops` because it allows a user to declaratively pin the nixpkgs version
used in the build.

1. Build the system

    ``` console
    [nix-shell] $ nixops deploy -d $NAME_OF_THE_DEPLOYMENT --boot --dry-run
    ```

2. Deploy (the active system configuration will be changed)

    ``` console
    $ ./result
    ```

3. Alternatively reboot the machine

    ``` console
    $ shutdown -r now
    ```

## Updating

1. Update the dependencies

    ``` console
    $ nix-shell
    [nix-shell]$ niv update
    Updating all packages
      Package: nixpkgs
      ...
    Done: Updating all packages
    ```

2. Rebuild

    ``` console
    $ nix-build deployment.nix
    ```

3. Activate the system configuration

    ``` console
    $ ./result
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

### TODOS

Packages to add to my configuration:

- <https://github.com/jtheoff/swappy> blocked by <https://github.com/NixOS/nixpkgs/pull/81116>
