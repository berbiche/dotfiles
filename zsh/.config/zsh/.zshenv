#!/bin/zsh

#export XDG_CONFIG_DIRS="/etc/xdg"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
#export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export XDG_DATA_HOME="$HOME/.local/share"

# ZSH History file
export HISTFILE="$XDG_CACHE_HOME/zsh/history"

# QT WAYLAND
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"

# Color man pages
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS='-r --quit-if-one-screen'

# 24-bit color
export COLORTERM=truecolor
export EDITOR=`which vim`

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

