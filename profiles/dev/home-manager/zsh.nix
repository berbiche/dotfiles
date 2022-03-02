{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in
{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableVteIntegration = isLinux;
    enableSyntaxHighlighting = true;
    dotDir = ".config/zsh";

    defaultKeymap = "emacs";

    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
      path = "${config.xdg.dataHome}/zsh/history";
      share = false;
      size = 100000;
      save = 100000;
    };

    sessionVariables = {
      COLORTERM = "truecolor";
      # ZSH_AUTOSUGGEST
      ZSH_AUTOSUGGEST_COMPLETION_IGNORE = "*/nix/store/*|rsync *|scp *|*/tmp/*";
    };

    plugins = [
      {
        src = pkgs.fetchFromGitHub {
          owner = "zimfw";
          repo = "completion";
          rev = "db079f405397a9dc9af93883e47d8adff817e3b1";
          hash = "sha256-LNVKj/85zkYPjpfDDhlxErwFmjVY/vwr07GBQJGUU+0=";
        };
        name = "completion";
        file = "init.zsh";
      }
    ];

    initExtra = ''
      # Hello message
      (
      echo $USER@$HOST  $(uname -srm) \
        $(sed -n 's/^NAME=//p' /etc/os-release 2>/dev/null || printf "") \
        $(sed -n 's/^VERSION=//p' /etc/os-release 2>/dev/null || printf "")
      ) || true

      ## VERY IMPORTANT!!!!
      unset RPS1 RPROMPT


      setopt incappendhistory
      setopt histfindnodups
      setopt histreduceblanks
      unsetopt histignorealldups                                      # If a new command is a duplicate, do not remove the older one
      setopt appendhistory                                            # Immediately append history instead of overwriting
      setopt histverify                                               # When expanding the last command with !! or !?, do not execute, substitute instead
      setopt correct                                                  # Auto correct mistakes
      #setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
      setopt nocaseglob                                               # Case insensitive globbing
      setopt rcexpandparam                                            # Array expension with parameters
      #setopt nocheckjobs                                              # Don't warn about running processes when exiting
      setopt numericglobsort                                          # Sort filenames numerically when it makes sense
      setopt beep                                                     # Enable beep
      setopt interactivecomments                                      # Allow using # in an interactive shell for comments

      setopt listbeep                                                 # Beep on ambiguous completion
      setopt listrowsfirst                                            # Order completions in row-form instead of column-form
      #setopt printexitvalue                                           # Print non-zero exit value in interactive prompts

      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"       # Colored completion (different colors for dirs/files/etc)
      zstyle ':completion:*' rehash true                              # automatically find new executables in path
      # Speed up completions
      zstyle ':completion:*' accept-exact '*(N)'
      zstyle ':completion:*' use-cache on
      mkdir -p "$(dirname ${config.xdg.cacheHome}/zsh/completion-cache)"
      zstyle ':completion:*' cache-path "${config.xdg.cacheHome}/zsh/completion-cache"
      # Fish-like completion (https://unix.stackexchange.com/a/467852)
      zmodload zsh/complist

      # Important
      WORDCHARS=''${WORDCHARS//[\/&.;_-]}                                 # Don't consider certain characters part of the word

      ## Keybindings section
      bindkey '^[[7~' beginning-of-line                               # Home key
      bindkey '^[[H' beginning-of-line                                # Home key
      if [[ "''${terminfo[khome]}" != "" ]]; then
        bindkey "''${terminfo[khome]}" beginning-of-line                # [Home] - Go to beginning of line
      fi
      bindkey '^[[8~' end-of-line                                     # End key
      bindkey '^[[F' end-of-line                                     # End key
      if [[ "''${terminfo[kend]}" != "" ]]; then
        bindkey "''${terminfo[kend]}" end-of-line                       # [End] - Go to end of line
      fi
      bindkey '^[[3~' delete-char                                     # Delete key
      bindkey '^[[5~' history-beginning-search-backward               # Page up key
      bindkey '^[[6~' history-beginning-search-forward                # Page down key

      # Navigate words with ctrl+arrow keys
      bindkey '^[[Z' undo                                             # Shift+tab undo last action

      # Local history (taken from https://superuser.com/a/691603)
      bindkey "^[OA"   up-line-or-local-history
      bindkey "^[OB" down-line-or-local-history

      # Global history on <C-Up>/<C-Down>
      bindkey "^[[1;5A" up-line-or-history
      bindkey "^[[1;5B" down-line-or-history

      # Ctrl-Z to foreground task in prompt
      # This also allows use of Ctrl-Z to background a task
      _zsh_cli_fg() { fg; }
      zle -N _zsh_cli_fg
      bindkey '^Z' _zsh_cli_fg

      #
      # From https://www.zsh.org/mla/users/2007/msg00976.html
      # Author: Mikael Magnusson
      _space_toggle() {
        if [[ $BUFFER[1] != " " ]]; then
          BUFFER=" $BUFFER"
          (( CURSOR+=1 ))
        else
          (( CURSOR-=1 ))
          BUFFER=$BUFFER[2,-1]
        fi
      }
      zle -N _space_toggle
      bindkey '^[z' _space_toggle

      up-line-or-local-history() {
          zle set-local-history 1
          zle up-line-or-history
          zle set-local-history 0
      }
      zle -N up-line-or-local-history
      down-line-or-local-history() {
          zle set-local-history 1
          zle down-line-or-history
          zle set-local-history 0
      }
      zle -N down-line-or-local-history

      # https://nuclearsquid.com/writings/edit-long-commands/
      # Somehow this was missing from my shell?
      autoload -U edit-command-line
      zle -N edit-command-line
      bindkey '^xe' edit-command-line
      bindkey '^x^e' edit-command-line

      # Theming section
      autoload -U colors
      colors

      nrsf() {
        ${lib.optionalString isLinux ''
          local cmd=(sudo nixos-rebuild switch --flake ~/dotfiles -v -L)
        ''}
        ${lib.optionalString isDarwin ''
          local cmd=(darwin-rebuild switch --flake ~/dotfiles -v -L)
        ''}
        echo "''${cmd[@]}" "$@"
        "''${cmd[@]}" "$@"
      }

      hmsf() {
        local cmd=(home-manager switch --flake ~/dotfiles -v)
        echo "''${cmd[@]}" "$@"
        "''${cmd[@]}" "$@"
      }
    '';
  };
}
