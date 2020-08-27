{ config, pkgs, lib, ... }:

let
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isDarwin isLinux;
in
lib.mkMerge [
  {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      shellInit = ''
        export XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
        export XDG_DATA_HOME=''${XDG_DATA_HOME:-$HOME/.local/share}
        export XDG_CACHE_HOME=''${XDG_CACHE_HOME:-$HOME/.cache}
        export ZDOTDIR=''${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}
      '';
    };
  }
  (lib.optionalAttrs isLinux {
    programs.zsh.syntaxHighlighting.enable = true;
  })
  {
    environment.pathsToLink = [ "/share/zsh" ];

    home-manager.users.${config.my.username} = { config, lib, pkgs, ... }: {
      programs.zsh = {
        enable = true;
        enableAutosuggestions = true;
        enableCompletion = true;
        dotDir = ".config/zsh";

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
        };

        shellAliases = rec {
          ".."   = "cd ..";
          ls      = "exa --color=auto --group-directories-first --classify";
          lst     = "${ls} --tree";
          la      = "${ls} --all";
          ll      = "${ls} --all --long --header --group";
          llt     = "${ll} --tree";
          tree    = "${ls} --tree";
          cdtemp  = "cd `mktemp -d`";
          cp      = "cp -iv";
          ln      = "ln -v";
          mkdir   = "mkdir -vp";
          mv      = "mv -iv";
          rm      = "rm -Iv";
          dh      = "du -h";
          df      = "df -h";
          su      = "sudo -E su -m";
          sysu    = "systemctl --user";
          jnsu    = "journalctl --user";
          svim    = "sudoedit";
          zreload = "export ZSH_RELOADING_SHELL=1; source $ZDOTDIR/.zshenv; source $ZDOTDIR/.zshrc; unset ZSH_RELOADING_SHELL";
        };

        profileExtra = ''
          setopt incappendhistory
          setopt histfindnodups
          setopt histreduceblanks
          setopt histverify
          setopt correct                                                  # Auto correct mistakes
          setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
          setopt nocaseglob                                               # Case insensitive globbing
          setopt rcexpandparam                                            # Array expension with parameters
          #setopt nocheckjobs                                              # Don't warn about running processes when exiting
          setopt numericglobsort                                          # Sort filenames numerically when it makes sense
          unsetopt nobeep                                                 # Enable beep
          setopt appendhistory                                            # Immediately append history instead of overwriting
          unsetopt histignorealldups                                      # If a new command is a duplicate, do not remove the older one
          setopt interactivecomments

          zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
          zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"       # Colored completion (different colors for dirs/files/etc)
          zstyle ':completion:*' rehash true                              # automatically find new executables in path 
          # Speed up completions
          zstyle ':completion:*' accept-exact '*(N)'
          zstyle ':completion:*' use-cache on
          mkdir -p "$(dirname ${config.xdg.cacheHome}/zsh/completion-cache)"
          zstyle ':completion:*' cache-path "${config.xdg.cacheHome}/zsh/completion-cache"
          zstyle ':completion:*' menu select

          WORDCHARS=''${WORDCHARS//\/[&.;]}                                 # Don't consider certain characters part of the word
        '';

        initExtra = ''
          if [ -z $ZSH_RELOADING_SHELL - ]; then
            echo $USER@$HOST  $(uname -srm) \
              $(sed -n 's/^NAME=//p' /etc/os-release 2>/dev/null || printf "") \
              $(sed -n 's/^VERSION=//p' /etc/os-release 2>/dev/null || printf "")
          fi

          # Migrate history from $XDG_CACHE_HOME to $XDG_DATA_HOME
          if [[ ${config.xdg.cacheHome}/zsh/history -nt ${config.xdg.dataHome}/zsh/history ]]; then
            echo "Migrating ZSH history to \$XDG_DATA_HOME"
            mkdir -p $(dirname ${config.xdg.dataHome}/zsh/history)
            [ -e ${config.xdg.dataHome}/zsh/history ] && mv ${config.xdg.dataHome}/zsh/history ${config.xdg.dataHome}/zsh/history.old
            mv ${config.xdg.cacheHome}/zsh/history ${config.xdg.dataHome}/zsh/history
          fi

          ## Keybindings section
          bindkey -e
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
          bindkey '^[[2~' overwrite-mode                                  # Insert key
          bindkey '^[[3~' delete-char                                     # Delete key
          bindkey '^[[C'  forward-char                                    # Right key
          bindkey '^[[D'  backward-char                                   # Left key
          bindkey '^[[5~' history-beginning-search-backward               # Page up key
          bindkey '^[[6~' history-beginning-search-forward                # Page down key

          # Navigate words with ctrl+arrow keys
          bindkey '^[Oc' forward-word                                     #
          bindkey '^[Od' backward-word                                    #
          bindkey '^[[1;5D' backward-word                                 #
          bindkey '^[[1;5C' forward-word                                  #
          bindkey '^H' backward-kill-word                                 # delete previous word with ctrl+backspace
          bindkey '^[[Z' undo                                             # Shift+tab undo last action

          # Theming section  
          autoload -U colors
          colors
        '';
      };
    };
  }
]
