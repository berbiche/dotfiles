{ config, options, lib, pkgs, ... }:

let
  mkCommand = commands: lib.concatStringsSep "; \\\n" commands;

  # Helpers for `for_window` commands
  mkFloatingBorder = { criteria, extraCommands ? [ ] }: {
    inherit criteria;
    command = mkCommand ([ "floating enable" "border normal" ] ++ extraCommands);
  };
  mkFloatingNoBorder = { criteria, extraCommands ? [] }: {
    inherit criteria;
    command = mkCommand ([ "floating enable" "border none" ] ++ extraCommands);
  };
  mkFloatingSticky = criteria: {
    inherit criteria;
    command = mkCommand [ "floating enable" "sticky enable" ];
  };
  mkInhibitFullscreen = criteria: {
    inherit criteria;
    command = "inhibit_idle fullscreen";
  };
  mkMarkSocial = name: criteria: {
    inherit criteria;
    command = "mark \"_social_${name}\"";
  };

  OUTPUT-HOME-DELL = "Dell Inc. DELL U3219Q F9WNWP2";
  OUTPUT-LAPTOP = "eDP-1";

  # Sway variables
  imagePath = toString config.programs.swaylock.imagePath;

  binaries = rec {
    terminal = "${config.my.defaults.terminal} --working-directory ${config.home.homeDirectory}";
    floating-term = "${terminal} --class='floating-term'";
    explorer = "${config.my.defaults.file-explorer}";
    browser = "env MOZ_DBUS_REMOTE=1 MOZ_ENABLE_WAYLAND=1 ${firefox}";
    browser-private = "${firefox} --private-window";
    browser-work-profile = "${firefox} -P job";
    lock = "${pkgs.systemd}/bin/loginctl lock-session";
    logout-menu = "${wlogout}";
    audiocontrol = "${pavucontrol}";
    #menu = "${nwggrid} -n 10 -fp -b 121212E0";
    #menu = "${pkgs.bash}/bin/bash -i -c '${xfce4-appfinder} --disable-server'";
    fullscreen-menu = "${pkgs.bash}/bin/bash -lc '${nwggrid-client}'";
    # Execute in "login" bash shell to inherit shell variables
    menu-wofi = "${pkgs.bash}/bin/bash -lc '${wofi} --fork --show drun,run'";
    menu-rofi = "${pkgs.bash}/bin/bash -lc ${pkgs.writeShellScript "rofi" ''
      ${rofi} -show drun -modi drun,run,calc,emoji -display-drun 'Launch' -theme slate
    ''}";

    on-startup-shutdown = pkgs.runCommandLocal "sway-on-startup-shutdown" {
      src = pkgs.fetchFromGitHub {
        owner = "alebastr";
        repo = "sway-systemd";
        rev = "0e87499359f2d5258f369531f88cc225ebd7cf48";
        hash = "sha256-HCNYWrEIqgnVkIEjcWkTmO34v0QwqujIlpkfeYgqBjQ=";
      };
      nativeBuildInputs = [ pkgs.makeWrapper ];
      BINS = lib.makeBinPath [ pkgs.systemd pkgs.dbus pkgs.sway ];
    } ''
      mkdir -p $out/bin
      install -Dm755 $src/src/session.sh $out/bin/session.sh
      # echo 'systemctl --user stop wayland-session.target' >> $out/bin/session.sh
      wrapProgram $out/bin/session.sh --set PATH "$BINS"
    '';

    alacritty = "${config.programs.alacritty.package}/bin/alacritty";
    bitwarden = "${pkgs.bitwarden}/bin/bitwarden";
    brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl -m";
    brightnessctl-avizo = config.lib.my.getScript "brightness-avizo.sh";
    emacsclient = "${config.programs.emacs.finalPackage}/bin/emacsclient -c";
    firefox = "${config.programs.firefox.package}/bin/firefox";
    nwggrid-client = "${pkgs.nwg-launchers}/bin/nwggrid -client";
    nwggrid-server = "${pkgs.nwg-launchers}/bin/nwggrid-server";
    pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
    playerctl = "${pkgs.playerctl}/bin/playerctl --player=spotify,mpv";
    element-desktop = "${pkgs.element-desktop}/bin/element-desktop";
    signal-desktop = "${pkgs.signal-desktop}/bin/signal-desktop";
    nwggrid = "${pkgs.nwg-launchers}/bin/nwggrid";
    nwgbar = "${pkgs.nwg-launchers}/bin/nwgbar";
    rofi = "${config.programs.rofi.finalPackage}/bin/rofi";
    spotify = "${pkgs.spotify}/bin/spotify";
    swaylock = "${pkgs.swaylock}/bin/swaylock";
    # swaymsg = "${config.wayland.windowManager.sway.package}/bin/swaymsg";
    swaymsg = "${pkgs.sway}/bin/swaymsg";
    wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
    # vvvv Requires my wlogout overlay
    wlogout = "${config.programs.wlogout.package}/bin/wlogout -p layer-shell";
    wofi = "${pkgs.wofi}/bin/wofi";
    xfce4-appfinder = "${pkgs.xfce.xfce4-appfinder}/bin/xfce4-appfinder";
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

  extraConfig = with workspaces; let
    makeCommand = (i: x: "exec_always ${binaries.swaymsg} rename workspace number ${toString i} to '${x}'");
    workspaces = [ WS1 WS2 WS3 WS4 WS5 WS6 WS7 WS8 WS9 WS10 ]; # Lexical ordering...
  in ''
    ${lib.concatImapStringsSep "\n" (makeCommand) workspaces}

    hide_edge_borders --i3 smart_no_gaps

    # Set default workspace outputs
    workspace "${WS5}" output "${OUTPUT-HOME-DELL}"
    workspace "${WS6}" output "${OUTPUT-HOME-DELL}"
    # workspace "${WS7}" output ""

    # Enable/Disable the output when closing the lid (e.g. when using a dock)
    bindswitch --reload --locked lid:on  output ${OUTPUT-LAPTOP} disable
    bindswitch --reload --locked lid:off output ${OUTPUT-LAPTOP} enable

    # Set default cursor size
    seat default xcursor_theme ${config.xsession.pointerCursor.name} ${toString config.xsession.pointerCursor.size}

    # We want to execute this last otherwise Waybar doesn't read the workspace names correctly
    exec ${binaries.on-startup-shutdown}/bin/session.sh --with-cleanup

    # Switch to first workspace on start
    workspace "${WS1}"
  '';

  swayConfig = with workspaces; {
    inherit (binaries) terminal;
    modifier = "Mod4";
    floating.modifier = "Mod4";
    # menu = binaries.menu-wofi;
    menu = binaries.menu-rofi;

    fonts = {
      names = [ "FontAwesome" "FontAwesome5Free" "Fira Sans" "DejaVu Sans Mono" ];
      size = 11.0;
    };

    colors = let
      darkblue = "#08052b";
      lightblue = "#5294e2";
      urgrentred = "#e53935";
      white = "#ffffff";
      black = "#000000";
      darkgrey = "#373c4a";
      grey = "#b0b5bd";
      mediumgrey = "#8b8b8b";
      yellowbrown = "#e1b700";
    in rec {
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

    focus.newWindow = "smart";
    gaps = {
      inner = 5;
      smartGaps = false; # Always display gaps
      smartBorders = "on"; # Hide borders even with gaps
      # Following option needs to be set in extraConfig
      # window.hideEdgeBorders = "smart_no_gaps";
    };
    window = {
      titlebar = true;
      border = 1;
    };
    floating = {
      titlebar = true;
      border = 1;
    };
    workspaceLayout = "default";
    workspaceAutoBackAndForth = false;

    output = {
      "*" = { bg = "${imagePath} center"; };
      "eDP-1" = {
        mode = "3840x2160@60Hz";
        scale_filter = "smart";
        scale = "2";
      };
    };

    input = import ./inputs.nix;

    floating.criteria = [
      { app_id = "floating-term"; }
      { app_id = "org.gnome.Nautilus"; }
      { app_id = "nemo"; }
      { app_id = "file-roller"; title = "Extract"; }
      { app_id = "file-roller"; title = "Compress"; }
      { title = "feh.*/Pictures/screenshots/.*"; }
      { app_id = "firefox"; title = "Developer Tools"; }
    ];

    startup = [
      { command = binaries.element-desktop; }
      { command = binaries.spotify; }
      { command = binaries.signal-desktop; }
      {
        always = true;
        command = let
          gsettings = "${pkgs.glib.bin}/bin/gsettings";
          gnome-schema = "org.gnome.desktop.interface";
        in toString (pkgs.writeShellScript "sway-gsettings" ''
          ## Commented out because this doesn't follow the day/night theme logic
          # ${gsettings} set "${gnome-schema}" gtk-theme ${config.gtk.theme.name}
          ${gsettings} set "${gnome-schema}" icon-theme ${config.gtk.iconTheme.name}
          ${gsettings} set "${gnome-schema}" cursor-theme ${config.xsession.pointerCursor.name}
          ${gsettings} set "${gnome-schema}" cursor-size ${toString config.xsession.pointerCursor.size}
        '');
      }
      # { command = binaries.bitwarden; }
    ];

    keybindings = lib.myLib.callWithDefaults ./keybindings.nix {
      inherit config binaries options workspaces;
    };

    modes = lib.myLib.callWithDefaults ./modes.nix {
      inherit config binaries;
    };

    # Hopefully the windows remain focused without needing to use the focus command
    assigns = {
      # Games related
      "'${WS5}'" = [
        { instance = "Steam"; } { app_id = "steam"; }
        { app_id = "lutris"; }
      ];
      # Movie related stuff
      "'${WS6}'" = [
        { title = "^Netflix.*"; }
        { title = "^Plex.*"; }
      ];
      # Social stuff
      #"'${WS7}'" = [
      #  { con_mark = "_social.*"; }
      #  { con_mark = "_music-player.*"; }
      #];
    };

    window.commands = lib.flatten [
      (map mkInhibitFullscreen [
        { class = "Firefox"; }
        { app_id = "firefox"; }
        { instance = "Steam"; }
        { app_id = "lutris"; }
        { title = "^Zoom Cloud.*"; }
      ])
      (map (x: mkFloatingNoBorder { criteria = x; }) [
        { app_id = "^launcher$"; }
        { app_id = "xfce4-appfinder"; }
        { instance = "xfce4-appfinder"; }
        { app_id = "zenity"; }
        { app_id = "pdfarranger"; }
      ])
      (mkFloatingNoBorder {
        criteria = { app_id = "blueman-manager"; };
        extraCommands = [ "scratchpad move" "scratchpad show" ];
      })
      (map mkFloatingSticky [
        { app_id = "pavucontrol"; }
        { app_id = "gnome-calendar"; }
      ])
      {
        criteria = { class = "Spotify"; instance = "spotify"; };
        command = "mark --add _music-player.spotify";
      }
      (mkMarkSocial "element" { class = "Element"; })
      (mkMarkSocial "signal" { class = "Signal"; })
      (mkMarkSocial "bitwarden" { class = "Bitwarden"; })
      (mkMarkSocial "rocket" { class = "Rocket.Chat"; })
      (mkMarkSocial "caprine" { class = "Caprine"; })
      # assign [con_mark] does not work! So we do it here with a for_window
      (map (x: { command = "move to workspace '${WS7}'"; criteria = x; }) [
        { con_mark = "_social.*"; }
        { con_mark = "_music-player.*"; }
      ])
      (map (x: mkFloatingBorder { criteria = x; }) [
        { app_id = "org.kde.haruna"; }
      ])
      {
        criteria = { floating = ""; app_id = "firefox"; };
        command = "border none";
      }
    ];

    bars = lib.mkForce [];
  };
in
{
  inherit extraConfig;
  config = swayConfig;
}
