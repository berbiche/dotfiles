{ config, lib, pkgs, ... }:

let
  inherit (config.profiles.i3) binaries;
  ws = config.profiles.i3-sway.workspaces;

  # Window rules helpers
  mkInhibitFullscreen = criteria: {
    inherit criteria;
    command = "inhibit_idle fullscreen";
  };
  mkMarkSocial = name: criteria: {
    inherit criteria;
    command = "mark \"_social_${name}\"";
  };
in {
  xsession.windowManager.i3.config = {
    inherit (binaries) terminal;

    fonts = {
      names = [ "FontAwesome" "FontAwesome5Free" "Fira Sans" "DejaVu Sans Mono" ];
      size = 10.0;
    };

    menu = binaries.launcher;

    bars = [ ];

    gaps = {
      # Hack to always leave enough space for polybar at the top
      top = let
        polybarCfg = config.services.polybar.config."bar/main" or { };
        topGaps = (polybarCfg.height or 0) + 2 * (polybarCfg.offset-y or 0);
      in topGaps;
      inner = 5;
      smartGaps = false; # Always display gaps
      smartBorders = "on"; # Hide borders even with gaps
    };

    window = {
      titlebar = true;
      border = 1;
      hideEdgeBorders = "smart";
      commands = lib.flatten [
        (map mkInhibitFullscreen [
          { class = "Firefox"; }
          { instance = "Steam"; }
          { instance = "lutris"; }
          { title = "^Zoom Cloud.*"; }
        ])
        (map (x: { command = "floating enable, border none"; criteria = x; }) [
          { instance = "xfce4-appfinder"; }
          { instance = "floating-term"; }
          { instance = "pavucontrol"; }
          { instance = "gnome-panel"; title = "Calendar"; }
        ])
        {
          command = "floating enable, border none";
          criteria.instance = "avizo-service";
        }
        (map (x: { command = "move to workspace '${ws.WS7}'"; criteria = x; }) [
          { con_mark = "_social.*"; }
          { con_mark = "_music-player.*"; }
        ])
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
        command = "--no-startup-id ${v.command}";
        notification = v.notification or false;
      }) [
        { command = binaries.disableCompositing; always = true; }
        { command = binaries.startX11SessionTarget; }
        { command = binaries.spotify; }
        { command = binaries.element-desktop; }
        { command = binaries.light-locker; }
        { command = binaries.wallpaper; }
        { command = binaries.override-gaps-settings; always = true; }
        { command = binaries.unclutter; }
      ];
  };

  xsession.windowManager.i3.extraConfig = ''
    no_focus [instance="avizo-service"]
  '';
}
