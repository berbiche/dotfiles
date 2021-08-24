{ config, options, lib, pkgs, ... }:

let
  inherit (config.lib.my) callWithDefaults;

  mkCommand = commands: lib.concatStringsSep "; \\\n" commands;

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
  imageFolder = toString config.programs.swaylock.imageFolder;
  wobsocket = "$XDG_RUNTIME_DIR/wob.sock";

  binaries = rec {
    terminal = "${alacritty} --working-directory ${config.home.homeDirectory}";
    floating-term = "${terminal} --class='floating-term'";
    explorer = "${nautilus}";
    browser = pkgs.writeScript "firefox" ''
      export MOZ_DBUS_REMOTE=1
      export MOZ_ENABLE_WAYLAND=1
      ${firefox} "$@"
    '';
    browser-private = "${browser} --private-window";
    browser-work-profile = "${browser} -P job";
    lock = "${swaylock} -f -c 0f0f0ff0 -i ${imageFolder}/current";
    logout-menu = "${wlogout}";
    audiocontrol = "${pavucontrol}";
    #menu = "${nwggrid} -n 10 -fp -b 121212E0";
    menu = "${pkgs.bash}/bin/bash -c '${xfce4-appfinder} --disable-server'";
    # Execute in bash shell to inherit shell variables
    menu-wofi = "${pkgs.bash}/bin/bash -c '${wofi} --fork --show drun,run'";

    on-startup-shutdown = pkgs.runCommandLocal "sway-on-startup-shutdown" {
      src = pkgs.fetchFromGitHub {
        owner = "alebastr";
        repo = "sway-systemd";
        rev = "v0.1.2";
        hash = "sha256-dQrCT9S36ebwMzNf7Xfu4914wCEPEA02VnneyaUm1U8=";
      };
      nativeBuildInputs = [ pkgs.makeWrapper ];
      BINS = lib.makeBinPath (with pkgs; [ systemd dbus sway ]);
    } ''
      mkdir -p $out/bin
      install -Dm755 $src/src/session.sh $out/bin/session.sh
      # echo 'systemctl --user stop wayland-session.target' >> $out/bin/session.sh
      wrapProgram $out/bin/session.sh --set PATH "$BINS"
    '';

    alacritty = "${pkgs.alacritty}/bin/alacritty";
    bitwarden = "${pkgs.bitwarden}/bin/bitwarden";
    brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl -m";
    brightnessctl-wob = toString (pkgs.writeShellScript "brightnessctl-wob" ''
      cut -d, -f4 | tr -d '%' |
        if [ -p "${wobsocket}" ]; then
          ${pkgs.coreutils}/bin/timeout --kill-after=5 5 ${pkgs.coreutils}/bin/cat > ${wobsocket} ;
        fi
    '');
    emacsclient = "${config.programs.emacs.finalPackage}/bin/emacsclient -c";
    # Firefox from the overlay
    firefox = "${pkgs.firefox}/bin/firefox";
    nautilus = "${pkgs.gnome3.nautilus}/bin/nautilus";
    pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
    playerctl = "${pkgs.playerctl}/bin/playerctl '--player=spotify,mpv'";
    element-desktop = "${pkgs.element-desktop}/bin/element-desktop";
    signal-desktop = "${pkgs.signal-desktop}/bin/signal-desktop";
    nwggrid = "${pkgs.nwg-launchers}/bin/nwggrid";
    nwgbar = "${pkgs.nwg-launchers}/bin/nwgbar";
    spotify = "${pkgs.spotify}/bin/spotify";
    swaylock = "${pkgs.swaylock}/bin/swaylock";
    # swaymsg = "${config.wayland.windowManager.sway.package}/bin/swaymsg";
    swaymsg = "${pkgs.sway}/bin/swaymsg";
    wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
    # vvvv Requires my wlogout overlay
    wlogout = "${pkgs.wlogout}/bin/wlogout -p layer-shell";
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
    bindswitch --locked lid:on  output ${OUTPUT-LAPTOP} disable
    bindswitch --locked lid:off output ${OUTPUT-LAPTOP} enable

    # Set default cursor size
    seat seat0 xcursor_theme ${config.xsession.pointerCursor.name} ${toString config.xsession.pointerCursor.size}

    # We want to execute this last otherwise Waybar doesn't read the workspace names correctly
    exec ${binaries.on-startup-shutdown}/bin/session.sh --with-cleanup
  '';

  swayConfig = with workspaces; {
    inherit (binaries) terminal;
    modifier = "Mod4";
    floating.modifier = "Mod4";
    menu = binaries.menu-wofi;

    fonts = {
      names = [ "FontAwesome" "FontAwesome5Free" "Fira Sans" "DejaVu Sans Mono" ];
      size = 9.0;
    };

    colors = rec {
      focused = let color = "${config.my.colors.color8}"; in {
        border = color;
        background = color;
        # Default colors
        text = "#ffffff";
        indicator = "#000000";
        childBorder = color;
      };
      # focusedInactive = let color = "${config.my.colors.color8}c0"; in {
      #   border = color;
      #   background = color;
      #   # Default colors
      #   text = "#ffffff";
      #   indicator = "#484e50";
      #   childBorder = color;
      # };
      focusedInactive = unfocused;
      unfocused = let color = "${config.my.colors.color9Darker}c0"; in {
        border = color;
        background = color;
        text = "#e6e6e6";
        # Default color
        indicator = "#292d2e";
        childBorder = color;
      };
      urgent = let color = "${config.my.colors.colorF}"; in {
        border = color;
        background = color;
        # Default colors
        text = "#ffffff";
        indicator = "#900000";
        childBorder = color;
      };
    };

    focus.newWindow = "focus";
    gaps = {
      inner = 5;
      smartGaps = false; # Always display gaps
      smartBorders = "on"; # Hide borders even with gaps
      # Following option needs to be set in extraConfig
      # window.hideEdgeBorders = "smart_no_gaps";
    };
    window = {
      titlebar = false;
      border = 3;
    };
    floating = {
      titlebar = true;
      border = 1;
    };
    workspaceLayout = "default";
    workspaceAutoBackAndForth = false;

    output = {
      "*" = { bg = "${imageFolder}/current center"; };
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
      { title = "feh.*/Pictures/screenshots/.*"; }
      { app_id = "firefox"; title = "Developer Tools"; }
    ];

    startup = [
      { command = binaries.element-desktop; }
      { command = binaries.spotify; }
      { command = binaries.signal-desktop; }
      # { command = binaries.bitwarden; }
    ];

    keybindings = callWithDefaults ./keybindings.nix {
      inherit config binaries options workspaces;
    };

    modes = callWithDefaults ./modes.nix {
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
    ];

    bars = lib.mkForce [];
  };
in
{
  inherit extraConfig;
  config = swayConfig;
}
