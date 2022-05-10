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

  # Hack to always leave enough space for polybar at the top
  polybarCfg = config.services.polybar.config."bar/main" or { };
  topGaps = (polybarCfg.height or 0) + 2 * (polybarCfg.offset-y or 0);
  xrdbHackCmd = ''
    ${lib.getBin pkgs.xorg.xrdb}/bin/xrdb -merge ${pkgs.writeText "i3-flashback-xresources" ''
      i3-wm.gaps.top: 0
    ''}
  '';
in {
  # The hack above is not necessary when running from a Gnome Flashback session
  xsession.initExtra = lib.mkAfter ''
    if [[ "''${XDG_CURRENT_DESKTOP-}" =~ "GNOME-Flashback" ]]; then
      ${xrdbHackCmd}
    fi
  '';
  home.activation.flashback-xrdb = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ "''${XDG_CURRENT_DESKTOP-}" =~ "GNOME-Flashback" ]]; then
      $DRY_RUN_CMD ${xrdbHackCmd}
    fi
  '';

  xsession.windowManager.i3.config = {
    inherit (binaries) terminal;

    fonts = {
      names = [ "FontAwesome" "FontAwesome5Free" "Fira Sans" "DejaVu Sans Mono" ];
      size = 10.0;
    };

    menu = binaries.launcher;

    bars = [ ];

    gaps = {
      inner = 5;
      smartGaps = false; # Always display gaps
      smartBorders = "on"; # Hide borders even with gaps
    };

    assigns = {
      ${ws.WS7} = [
        { con_mark = "_social.*"; }
        { con_mark = "_music-player.*"; }
      ];
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
          { instance = "pavucontrol"; }
          { instance = "gnome-panel"; title = "Calendar"; }
          { instance = "gnome-control-center"; }
          { instance = "avizo-service"; }
        ])
        (map (x: { command = "floating enable"; criteria = x; }) [
          { instance = "floating-term"; }
        ])
        (mkMarkSocial "element" { class = "Element"; })
        (mkMarkSocial "signal" { class = "Signal"; })
        (mkMarkSocial "bitwarden" { class = "Bitwarden"; })
        (mkMarkSocial "caprine" { class = "Caprine"; })
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
        command = "${v.command}";
        notification = v.notification or false;
      }) [
        { command = binaries.disableCompositing; always = true; }
        { command = binaries.startX11SessionTarget; }
        { command = binaries.spotify; }
        { command = binaries.element-desktop; }
        { command = binaries.light-locker; }
        { command = binaries.wallpaper; }
        { command = binaries.unclutter; }
      ];
  };

  xsession.windowManager.i3.extraConfig = ''
    no_focus [instance="avizo-service"]

    set_from_resources $i3-wm.gaps.top i3-wm.gaps.top ${toString topGaps}
  '';
}
