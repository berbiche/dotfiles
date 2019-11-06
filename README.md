My configuration for the various tools I use.

This configuration is suited for my Thiccpad T580.

I use Sway on NixOS with the help of many scripts. I used to use Manjaro.

This repository lives under `$HOME/dotfiles` and I use [stow](https://www.gnu.org/software/stow/manual/stow.html)
to manage my configuration (symlinks all files and folders).

Clone this repository wherever, then run the following command
at the root of the repository
to check the changes that will be applied (and tweak whatever you need):

```sh
# ~/dotfiles on  master [⇡✘»!?]
stow -nv --target=$HOME .
```

Once you are satisfied, you can run the command _for real_:

```sh
# ~/dotfiles on  master [⇡✘»!?]
stow -v --target=$HOME .
```

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
