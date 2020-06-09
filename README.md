# Dotfiles

My configuration for the various tools I use.

I use [Sway](https://swaywm.org) (a tiling window manager running on Wayland) on NixOS on both my laptop and my desktop.


This repository lives under `$HOME/dotfiles` and I use [home-manager](https://github.com/rycee/home-manager) to manage
my configuration files and my packages.

I use Gnome Keyring to manage my secrets (SSH and GPG passwords) and to have
a graphical prompt to unlock my SSH keys.

## Building

Building can be done at two level:

- Rebuild only the user configuration with home-manager
- Rebuild the entire system configuration

1. Clone this repository.

    ``` console
    $ git clone https://github.com/berbiche/dotfiles
    $ cd dotfiles
    ```

2. Install [Nix package manager](https://nixos.org) for your distribution if not using NixOS.

### Rebuilding only the dotfiles with home-manager

3. Install [home-manager](https://github.com/rycee/home-manager). Make sure `$HOME/.nix-profile/bin`
   is in your `$PATH` (it should normally).

4. Install the configuration, this will install and symlink all required files as well as fetch
all packages (and binaries) specified in the configuration.

    ``` console
    $ home-manager -f home.nix switch
    ```

    home-manager may warn about files already existing outside the "store".  
    You can supplement a parameter to home-manager to rename old files/directories when
    installing with `-b bak` where `bak` will be the extension suffixed to old files.  
    See home-manager manpage.

### Rebuilding the system configuration, including home-manager

Note that required hardward configuration has to be done before building any host under `hosts/` (formatting drives, setting up the bootloader, etc.).

1. Create the `hostname` file with the name of the host to build. The host should exist under `hosts/${hostname}.nix`
   otherwise a compilation error will be reported.

    Example:

    ``` console
    $ echo "thixxos" >> hostname
    ```

2. Add the necessary channels (TODO: automate)

   ``` console
   $ sudo nix-channel --add https://nixos.org/channels/nixos-unstable

   $ sudo nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager

   $ sudo nix-channel --add https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz nixpkgs-mozilla

   $ sudo nix-channel --add https://github.com/colemickens/nixpkgs-wayland/archive/master.tar.gz nixpkgs-wayland

   $ sudo nix-channel --list
   home-manager https://github.com/rycee/home-manager/archive/master.tar.gz
   nixos https://nixos.org/channels/nixos-unstable
   nixpkgs-mozilla https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz
   nixpkgs-wayland https://github.com/colemickens/nixpkgs-wayland/archive/master.tar.gz

   $ sudo nix-channel --update
   ```

3. Build the system

   ``` console
   $ sudo nixos-rebuild boot -I nixos-config=./configuration.nix
   these derivations will be built:
     /nix/store/6dvwa00nx2sx5idq8gg5pq5ym6s7ih0j-nixos-rebuild.drv
   building '/nix/store/6dvwa00nx2sx5idq8gg5pq5ym6s7ih0j-nixos-rebuild.drv'...
   building Nix...
   building the system configuration... 
   ```

4. Reboot in the new system configuration

   ``` console
   $ shutdown -r now
   ```

## Updating

Rebuild with the `--upgrade` switch:

``` console
$ sudo nixos-rebuild switch --upgrade -I nixos-config=./configuration.nix
```

The path to the `configuration.nix` can either be relative or absolute.

If a build has already been made then the `-I nixos-config=./configuration.nix` switch in unecessary as the `$NIX_PATH` environment variable has been changed for `nixos-config` to point to the initial installation folder.

## Configuration

Most programs configuration live under `home-manager/programs`.

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

