My configuration for the various tools I use.

This configuration is suited for my Thiccpad T580.

I use Sway on Manjaro Linux with the help of many scripts.

This repository lives under `$HOME/dotfiles` and I use [stow](https://www.gnu.org/software/stow/manual/stow.html)
to manage my configuration (symlinks all files and folders).

The ZSH configuration requires the following code in `/etc/zsh/zshenv`:

```zsh
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}

export ZDOTDIR=${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}
export HISTFILE="$XDG_DATE_HOME/zsh/history"

# For command completions
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
```
