#export XDG_CONFIG_DIRS="/etc/xdg"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
#export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export XDG_DATA_HOME="$HOME/.local/share"

# ZSH History file
export HISTFILE="$XDG_CACHE_HOME/zsh/history"

# GPG
#export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.ssh"

# Gnome Keyring SSH
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/keyring/ssh"

# QT WAYLAND
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
# Mozilla Wayland
#export MOZ_ENABLE_WAYLAND=1
#export MOZ_WEBRENDER=1

# Color man pages
#export LESS_TERMCAP_mb=$'\E[01;32m'
#export LESS_TERMCAP_md=$'\E[01;32m'
#export LESS_TERMCAP_me=$'\E[0m'
#export LESS_TERMCAP_se=$'\E[0m'
#export LESS_TERMCAP_so=$'\E[01;47;34m'
#export LESS_TERMCAP_ue=$'\E[0m'
#export LESS_TERMCAP_us=$'\E[01;36m'
export LESS='--RAW-CONTROL-CHARS --quit-if-one-screen'

# FZF config
export FZF_DEFAULT_COMMAND='fd --follow --type f --exclude='"'.git'"' .'
export FZF_DEFAULT_OPTS='--exact --cycle --layout=reverse'

# 24-bit color
export COLORTERM=truecolor
# Editor as VIM
export EDITOR='nvim'
