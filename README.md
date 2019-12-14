# Dotfiles
My configuration for the various tools I use.

This configuration is suited for my Thiccpad T580.

I use Sway on NixOS on my laptop with the help of many scripts and I run Manjaro on my desktop.


This repository lives under `$HOME/dotfiles` and I use [stow](https://www.gnu.org/software/stow/manual/stow.html)
to manage my configuration (symlinks all files and folders).

I use Gnome Keyring to manage my secrets (SSH and GPG passwords) and to have
a graphical prompt to unlock my SSH keys.

## ZSH

Many aliases are defined in my ZSH config that requires packages to be installed
beforehand. Most of these tools have binaries provided on their Github page and
most should be packaged for your distro.

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
export HISTFILE="$XDG_DATA_HOME/zsh/history"

# For command completions
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
```

## Dependencies

My configuration depends on many dependencies not currently listed here.

## Installation

First, clone this repository.

Then, _stow_ each folder you need., then run the following command

```sh
# ~/dotfiles on  master [⇡✘»!?]
stow -nv --target=$HOME one_of_the_folders
```

The _-n_ flag forbids Stow to make changes (useful with the _-v_ erbose flag.

Once you are satisfied, you can run the command _for real_:

```sh
# ~/dotfiles on  master [⇡✘»!?]
stow -v --target=$HOME one_of_the_folders
```

If you want to link everything, you will need _fd_:

```sh
# ~/dotfiles on  master [⇡✘»!?]
fd --max-depth 1 -t d -x stow -v -t $HOME
```

