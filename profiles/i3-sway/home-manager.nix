{ config, lib, pkgs, ... }:

let
  darkblue = "#08052b";
  lightblue = "#5294e2";
  urgrentred = "#e53935";
  white = "#ffffff";
  black = "#000000";
  darkgrey = "#373c4a";
  grey = "#b0b5bd";
  mediumgrey = "#8b8b8b";
  yellowbrown = "#e1b700";

  colors = rec {
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
  };

  # Number at the start is used for ordering
  # https://github.com/Alexays/Waybar/blob/f233d27b782c04ef128e3d71ec32a0b2ce02df39/src/modules/sway/workspaces.cpp#L351-L357
  workspaces = {
    WS1 = "1:";      # browsing
    WS2 = "2:";      # school
    WS3 = "3:";      # dev
    WS4 = "4:";      # sysadmin
    WS5 = "5:";      # gaming
    WS6 = "6:";      # movie
    WS7 = "7:";      # social
    WS8 = "8";        # scratchpad
    WS9 = "9";        # scratchpad
    WS10 = "10";      # scratchpad
  };
in
{
  options.profiles.i3-sway.colors = lib.mkOption {
    type = let
      x = lib.types.attrsOf (lib.types.oneOf [ lib.types.str x ]);
    in x // { description = "Attribute set of attribute sets containing color configuration"; };
  };

  options.profiles.i3-sway.workspaces = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
  };

  options.profiles.i3-sway.modifier = lib.mkOption {
    type = lib.types.str;
    default = "Mod4";
  };

  config = {
    profiles.i3-sway.colors = lib.mkDefault colors;

    profiles.i3-sway.workspaces = lib.mkDefault workspaces;

    xsession.windowManager.i3.config.colors = config.profiles.i3-sway.colors;
    wayland.windowManager.sway.config.colors = config.profiles.i3-sway.colors;

    xsession.windowManager.i3.config.modifier = config.profiles.i3-sway.modifier;
    xsession.windowManager.i3.config.floating.modifier = config.profiles.i3-sway.modifier;
    wayland.windowManager.sway.config.modifier = config.profiles.i3-sway.modifier;
    wayland.windowManager.sway.config.floating.modifier = config.profiles.i3-sway.modifier;
  };
}
