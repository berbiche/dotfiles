# Source the base file
. $ZDOTDIR/base-zshrc

fpath=($fpath "${ZDOTDIR}/.zfunctions")

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
#powerline-daemon -q
#. /usr/share/powerline/bindings/zsh/powerline.zsh

# Set Spaceship ZSH as a prompt
autoload -U promptinit; promptinit
#SPACESHIP_PROMPT_ORDER=(
#  time          # Time stamps section
#  user          # Username section
#  dir           # Current directory section
#  host          # Hostname section
#  git           # Git section (git_branch + git_status)
#  hg            # Mercurial section (hg_branch  + hg_status)
#  package       # Package version
#  node          # Node.js section
#  ruby          # Ruby section
#  elixir        # Elixir section
#  xcode         # Xcode section
#  swift         # Swift section
#  golang        # Go section
#  php           # PHP section
#  rust          # Rust section
#  haskell       # Haskell Stack section
#  julia         # Julia section
#  docker        # Docker section
#  aws           # Amazon Web Services section
#  venv          # virtualenv section
#  conda         # conda virtualenv section
#  pyenv         # Pyenv section
#  dotnet        # .NET section
#  ember         # Ember.js section
#  kubecontext   # Kubectl context section
#  terraform     # Terraform workspace section
#  exec_time     # Execution time
#  #line_sep      # Line break
#  battery       # Battery level and status
#  vi_mode       # Vi-mode indicator
#  jobs          # Background jobs indicator
#  exit_code     # Exit code section
#  char          # Prompt character
#)
prompt spaceship

# Source aliases
. $ZDOTDIR/zaliases

unsetopt SHARE_HISTORY
unsetopt share_history
