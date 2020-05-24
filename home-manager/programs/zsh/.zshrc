# Source the base file if $ZDOTDIR is within HOME
if [[ "$(dirname "$ZDOTDIR")" == "$HOME"* ]]; then
  . $ZDOTDIR/base-zshrc
fi

fpath=($fpath "${ZDOTDIR}/.zfunctions")

eval "$(starship init zsh)"
eval "$(direnv hook zsh)"

# Source aliases if $ZDOTDIR is within HOME
if [[ "$(dirname "$ZDOTDIR")" == "$HOME"* ]]; then
  . $ZDOTDIR/.zshenv
  . $ZDOTDIR/zaliases
fi

unsetopt SHARE_HISTORY
unsetopt share_history

if [ -n "${commands[fzf-share]}" ]; then
  source "$(fzf-share)/key-bindings.zsh"
fi

if [ -z $ZSH_RELOADING_SHELL ]; then
  echo $USER@$HOST  $(uname -srm) \
    $(sed -n 's/^NAME=//p' /etc/os-release) \
    $(sed -n 's/^VERSION=//p' /etc/os-release)
fi
