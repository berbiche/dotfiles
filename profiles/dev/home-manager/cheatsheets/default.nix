{ config, lib, pkgs, ... }:

{
  programs.navi = {
    enable = true;
    settings = {
      finder = {
        command = "fzf"; # equivalent to the --finder option
        # overrides = "--tac" # equivalent to the --fzf-overrides option
        # overrides_var = "--tac" # equivalent to the --fzf-overrides-var option
      };
      cheats = {
        paths = [
          "${config.xdg.configHome}/cheatsheets"
        ];
      };
      # search:
      # tags: git,!checkout # equivalent to the --tag-rules option
    };
  };

  xdg.configFile = let
    files'' = builtins.attrNames (builtins.readDir ./.);
    files' = lib.filter (lib.hasSuffix ".cheat") files'';
    files = map (n: lib.nameValuePair "cheatsheets/${n}" { source = ./. + "/${n}"; }) files';
  in lib.listToAttrs files;
}
