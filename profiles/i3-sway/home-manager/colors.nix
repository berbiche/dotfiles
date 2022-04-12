{ config, lib, ... }:

{
  options.profiles.i3-sway.colors = lib.mkOption {
    type = let
      x = lib.types.attrsOf (lib.types.oneOf [ lib.types.str x ]);
    in x // { description = "Attribute set of attribute sets containing color configuration"; };
  };

  config.xsession.windowManager.i3.config.colors = config.profiles.i3-sway.colors;
  config.wayland.windowManager.sway.config.colors = config.profiles.i3-sway.colors;

  config.profiles.i3-sway.colors = let
    darkblue = "#08052b";
    lightblue = "#5294e2";
    urgrentred = "#e53935";
    white = "#ffffff";
    black = "#000000";
    darkgrey = "#373c4a";
    grey = "#b0b5bd";
    mediumgrey = "#8b8b8b";
    yellowbrown = "#e1b700";
  in lib.mkDefault (rec {
    focused = {
      border = lightblue;
      background = darkblue;
      text = white;
      indicator = lightblue;
      childBorder = mediumgrey;
    };
    focusedInactive = focused // {
      border = darkblue;
      text = grey;
      childBorder = black;
    };
    unfocused = focusedInactive // {
      border = darkgrey;
      childBorder = darkgrey;
    };
    urgent = focused // {
      border = urgrentred;
      background = urgrentred;
      childBorder = yellowbrown;
    };
  });
}
