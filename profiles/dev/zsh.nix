{ config, pkgs, lib, ... }:

let
  inherit (pkgs.stdenv.targetPlatform) isDarwin isLinux;
  inherit (lib) mkIf mkMerge;
in
{
  environment.pathsToLink = [ "/share/zsh" ];
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  my.home = { config, lib, pkgs, ... }: {
    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      dotDir = ".config/zsh";

      history = {
        expireDuplicatesFirst = true;
        ignoreDups = true;
        ignoreSpace = true;
        extended = false;
        path = "${config.xdg.dataHome}/zsh/history";
        share = true;
        size = 100000;
        save = 100000;
      };

      sessionVariables = {
        COLORTERM = "truecolor";
      };

      shellAliases = rec {
        ".."      = "cd ..";
        "..."     = "cd ../..";
        "...."    = "cd ../../..";
        "....."   = "cd ../../../..";
        ls        = "${pkgs.exa}/bin/exa --color=auto --group-directories-first --classify";
        lst       = "${ls} --tree";
        la        = "${ls} --all";
        ll        = "${ls} --all --long --header --group";
        llt       = "${ll} --tree";
        tree      = "${ls} --tree";
        batnp     = "${pkgs.bat}/bin/bat --pager=''";
        cdtemp    = "cd `mktemp -d`";
        cp        = "cp -iv";
        ln        = "ln -v";
        mkdir     = "mkdir -vp";
        mv        = "mv -iv";
        rm        = mkMerge [
          (mkIf isDarwin "rm -v")
          (mkIf (!isDarwin) "rm -Iv")
        ];
        dh        = "du -h";
        df        = "df -h";
        py        = "ptipython";
        su        = "sudo -E su -m";
        systemctl = "command systemctl --no-pager --full";
        sysu      = "${systemctl} --user";
        jnsu      = "journalctl --user";
        svim      = "sudoedit";
        trash     = lib.mkIf isLinux "gio trash";
      };

      initExtra = ''
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
        unsetopt nobeep                                                 # Enable beep
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
        zstyle ':completion:*' menu yes select search

        WORDCHARS=''${WORDCHARS//[\/&.;_-]}                                 # Don't consider certain characters part of the word

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

        # Local history (taken from https://superuser.com/a/691603)
        bindkey "^[OA"   up-line-or-local-history
        bindkey "^[OB" down-line-or-local-history

        # Global history on <C-Up>/<C-Down>
        bindkey "^[[1;5A" up-line-or-history
        bindkey "^[[1;5B" down-line-or-history

        # Ctrl-Z to foreground task in prompt
        _zsh_cli_fg() { fg; }
        zle -N _zsh_cli_fg
        bindkey '^Z' _zsh_cli_fg

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

        # Theming section
        autoload -U colors
        colors

        # ZSH_AUTOSUGGEST
        ZSH_AUTOSUGGEST_COMPLETION_IGNORE="*/nix/store/*|rsync *|scp *|*/tmp/*"


        ## VERY IMPORTANT!!!!
        unset RPS1 RPROMPT



        echo $USER@$HOST  $(uname -srm) \
          $(sed -n 's/^NAME=//p' /etc/os-release 2>/dev/null || printf "") \
          $(sed -n 's/^VERSION=//p' /etc/os-release 2>/dev/null || printf "")

        # Migrate history from $XDG_CACHE_HOME to $XDG_DATA_HOME
        if [[ ${config.xdg.cacheHome}/zsh/history -nt ${config.xdg.dataHome}/zsh/history ]]; then
          echo "Migrating ZSH history to \$XDG_DATA_HOME"
          mkdir -p $(dirname ${config.xdg.dataHome}/zsh/history)
          [ -e ${config.xdg.dataHome}/zsh/history ] && mv ${config.xdg.dataHome}/zsh/history ${config.xdg.dataHome}/zsh/history.old
          mv ${config.xdg.cacheHome}/zsh/history ${config.xdg.dataHome}/zsh/history
        fi
      '';
    };
  };
}
