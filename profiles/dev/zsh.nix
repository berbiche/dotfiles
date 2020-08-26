{ pkgs, lib, ... }:

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
]
