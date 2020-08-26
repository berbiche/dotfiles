{ config, ... }:

{
  home-manager.users.${config.my.username} = { config, ... }: {
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