# Source the base file
. $ZDOTDIR/base-zshrc

# Fix gpg
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

# Source fzf
. /usr/share/fzf/key-bindings.zsh
. /usr/share/fzf/completion.zsh

# Source fnm (node version manager)
if [[ $(fnm --version) > 1.9.1 ]]; then
  eval "`fnm env --multi --shell=zsh --base-dir=\"$HOME/.cache/fnm\"`"
else
  eval "`fnm env --multi --shell=zsh --fnm-dir=\"$HOME/.cache/fnm\"`"
fi

if [ -f ./.nvmrc ] || [ -f ~/.nvmrc ]; then
  fnm use $(cat ./.nvmrc 2&>/dev/null || cat ~/.nvmrc 2&>/dev/null)
  rehash
fi

# Powerline
powerline-daemon -q
. /usr/share/powerline/bindings/zsh/powerline.zsh

# Source aliases
. $ZDOTDIR/zaliases

unsetopt SHARE_HISTORY
unsetopt share_history

