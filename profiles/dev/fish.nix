{ config, ... }:

{
  home-manager.users.${config.my.username} = { ... }: {
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