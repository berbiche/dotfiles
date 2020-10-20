{ config, ... }:

{
  my.home = { config, ... }: {
    programs.fish = {
      enable = true;
      shellAbbrs = {
        "..."  = "../../";
        "...." = "../../../";
        "....." = "../../../../";
      };
      shellAliases = config.programs.zsh.shellAliases;
    };
  };
}