{ config, ... }:

{
  programs.fish = {
    enable = true;
    shellAbbrs = {
      "..."  = "../../";
      "...." = "../../../";
      "....." = "../../../../";
    };
  };
}
