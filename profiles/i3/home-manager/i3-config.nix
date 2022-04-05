{ config, lib, pkgs, ... }:

let
  inherit (config.profiles.i3) binaries;
in {
  xsession.windowManager.i3.config = {
    inherit (binaries) terminal;

    fonts = {
      names = [ "FontAwesome" "FontAwesome5Free" "Fira Sans" "DejaVu Sans Mono" ];
      size = 11.0;
    };

    menu = binaries.launcher;

    bars = [ ];

    gaps = {
      inner = 10;
      smartGaps = true;
      smartBorders = "on";
    };

    window = {
      titlebar = true;
      border = 1;
      hideEdgeBorders = "smart";
      commands = [
        {
          command = "floating enable";
          criteria.instance = "xfce4-appfinder";
        }
        {
          command = "floating enable";
          criteria.instance = "floating-term";
        }
      ];
    };
    floating = {
      titlebar = true;
      border = 1;
    };
    workspaceLayout = "default";
    workspaceAutoBackAndForth = false;

    startup =
      map (v: v // {
        command = if v ? command then "${v.command}" else null;
        notification = v.notification or false;
      }) [
        { command = binaries.disableCompositing; always = true; }
        { command = binaries.panel; }
        { command = binaries.fixXkeyboard; }
        { command = binaries.startX11SessionTarget; }
        { command = binaries.spotify; }
        { command = binaries.element-desktop; }
      ];
  };
}
