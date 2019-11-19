# source the base file
. $ZDOTDIR/base-zshrc

fpath=($fpath "${zdotdir}/.zfunctions")

# fix gpg
#export gpg_tty=$(tty)
#gpg-connect-agent updatestartuptty /bye >/dev/null

# source fzf
#. /usr/share/fzf/key-bindings.zsh
#. /usr/share/fzf/completion.zsh

# source fnm (node version manager)
#if [[ $(fnm --version) > 1.9.1 ]]; then
#  eval "`fnm env --multi --shell=zsh --base-dir=\"$home/.cache/fnm\"`"
#else
#  eval "`fnm env --multi --shell=zsh --fnm-dir=\"$home/.cache/fnm\"`"
#fi
#
#if [ -f ./.nvmrc ] || [ -f ~/.nvmrc ]; then
#  fnm use $(cat ./.nvmrc 2&>/dev/null || cat ~/.nvmrc 2&>/dev/null)
#  rehash
#fi

eval "$(starship init zsh)"

# Source aliases if ZDOTDIR is within home
if [[ "$(dirname "$ZDOTDIR")" == "$HOME"* ]]; then
  . $ZDOTDIR/.zshenv
  . $ZDOTDIR/zaliases
fi

unsetopt SHARE_HISTORY
unsetopt share_history

# Created by newuser for 5.7.1
if [ -n "${commands[fzf-share]}" ]; then
  source "$(fzf-share)/key-bindings.zsh"
fi

if [ -z $ZSH_RELOADING_SHELL ]; then
  echo $USER@$HOST  $(uname -srm) \
    $(sed -n 's/^NAME=//p' /etc/os-release) \
    $(sed -n 's/^VERSION=//p' /etc/os-release)
fi
