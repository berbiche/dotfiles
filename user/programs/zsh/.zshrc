# Source the base file if $ZDOTDIR is within HOME
if [[ "$(dirname "$ZDOTDIR")" == "$HOME"* ]]; then
  . $ZDOTDIR/base-zshrc
fi

# Source aliases if $ZDOTDIR is within HOME
if [[ "$(dirname "$ZDOTDIR")" == "$HOME"* ]]; then
  . $ZDOTDIR/.zshenv
  . $ZDOTDIR/zaliases
fi

if [ -z $ZSH_RELOADING_SHELL ]; then
  echo $USER@$HOST  $(uname -srm) \
    $(sed -n 's/^NAME=//p' /etc/os-release) \
    $(sed -n 's/^VERSION=//p' /etc/os-release)
fi
