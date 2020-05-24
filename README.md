# Dotfiles

My configuration for the various tools I use.

I use [Sway](https://swaywm.org) (a tiling window manager running on Wayland) on NixOS on both my laptop and my desktop.


This repository lives under `$HOME/dotfiles` and I use [home-manager](https://github.com/rycee/home-manager) to manage
my configuration files and my packages.

I use Gnome Keyring to manage my secrets (SSH and GPG passwords) and to have
a graphical prompt to unlock my SSH keys.

## Installation

1. Clone this repository.

    ``` console
    $ git clone https://github.com/berbiche/dotfiles
    $ cd dotfiles
    ```

2. Install [Nix package manager](https://nixos.org) for your distribution if not using NixOS.

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

## ZSH

Many aliases are defined in my ZSH config that requires packages to be installed
beforehand.

Most of the tools I use are written in Rust because I could hack on them if I
ever needed to.

- [exa](https://github.com/ogham/exa) (ls with --tree and other goodies)
- [bat](https://github.com/sharkdp/bat) (cat with syntax highlighting and pagination)
- [ripgrep](https://github.com/BurntSushi/ripgrep) (opiniated grep with defaults applied, claims to be faster than grep)
- [ripgrep-all](https://github.com/phiresky/ripgrep-all) (grep inside PDFs, E-Books, zip, etc.)
- [fd](https://github.com/sharkdp/fd) (find with a much more intuitive syntax to me)
- [tldr](https://github.com/tldr-pages/tldr) (super simple manpage consisting of examples)
- [neofetch](https://github.com/dylanaraps/neofetch) (get system information)
- [starship](https://github.com/starship/starship) (cool minimal shell prompt with git, nodejs, rust, go, etc. support)
- [hexyl](https://sharkdp/hexyl) (cli hex viewer, an alternative to xxd)

My ZSH configuration requires the following code in `/etc/zsh/zshenv` under Arch/Manjaro
or in `/etc/zshenv.local` under NixOS:

```zsh
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export ZDOTDIR=${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}
```

