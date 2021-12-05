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
    };
  };
}
