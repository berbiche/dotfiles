{ config, lib, pkgs, ... }:

{
  services.xserver.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
  };

  home-manager.users.${config.my.username} = { config, ... }:
    let
      mod = config.xsession.windowManager.i3.config.modifier;

      binaries = rec {
        terminal = "${alacritty} --working-directory ${config.home.homeDirectory}";
        floating-term = "${terminal} --class='floating-term'";
        explorer = nautilus;
        browser = firefox;
        browser-private = "${browser} --private-window";
        browser-work-profile = "${browser} -P job";
        audiocontrol = pavucontrol;
        launcher = xfce4-appfinder;
        menu = "${nwggrid} -n 10 -fp -b 121212E0";
        logout = "${pkgs.xfce.xfce4-session}/bin/xfce4-session-logout";
        panel = "${pkgs.xfce.xfce4-panel}/bin/xfce4-panel";
        locker = "${pkgs.lightlocker}/bin/light-locker-command -l";
        screenshot = "${pkgs.xfce.xfce4-screenshooter}/bin/xfce4-screenshooter";
        # screenshot = "${pkgs.flameshot}/bin/flameshot";

        alacritty = "${pkgs.alacritty}/bin/alacritty";
        bitwarden = "${pkgs.bitwarden}/bin/bitwarden";
        brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
        firefox = "${pkgs.firefox}/bin/firefox";
        nautilus = "${pkgs.gnome3.nautilus}/bin/nautilus";
        pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
        playerctl = "${pkgs.playerctl}/bin/playerctl";
        element-desktop = "${pkgs.element-desktop}/bin/element-desktop";
        nwggrid = "${pkgs.nwg-launchers}/bin/nwggrid";
        nwgbar = "${pkgs.nwg-launchers}/bin/nwgbar";
        spotify = "${pkgs.spotify}/bin/spotify";
        xfce4-appfinder = "${pkgs.xfce.xfce4-appfinder}/bin/xfce4-appfinder";

        fixXkeyboard = "${pkgs.writeScriptBin "fix-x-keyboard" ''
          xset r rate 200 30
          setxkbmap -layout us -option ctrl:swapcaps,compose:ralt
        ''}/bin/fix-x-keyboard";
      };
    in {
      xsession.windowManager.i3 = {
        enable = true;

        config = rec {
          modifier = "Mod4";
          floating.modifier = modifier;
          fonts = [ "DejaVu Sans Mono, FontAwesome 6" ];

          terminal = binaries.terminal;
          menu = binaries.xfce4-appfinder;

          bars = [ ];

          gaps = {
            inner = 6;
            smartGaps = true;
            smartBorders = "on";
          };

          window = {
            border = 1;
            titlebar = true;
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

          startup = [
            { command = "xfconf-query -c xfwm4 -p /general/use_compositing -s false"; always = true; notification = false; }
            { command = binaries.panel; notification = false; }
            { command = binaries.fixXkeyboard; notification = false; }
            {
              command = ''
                exec "systemctl --user import-environment; systemctl --user start x11-session.target"
              '';
              notification = false;
            }
          ];

          keybindings = lib.mkOptionDefault {
            "${mod}+Shift+q" = "exec ${binaries.logout}";
            "${mod}+Shift+e" = null;
            "${mod}+Shift+d" = "kill";

            "${mod}+Backspace" = "exec ${binaries.locker}";
            "${mod}+Shift+Backspace" = "exec ${binaries.logout}";

            "${mod}+Shift+Return" = "exec ${binaries.floating-term}";
            "${mod}+p" = "exec ${binaries.menu}";
            "${mod}+n" = "exec ${binaries.browser}";
            "${mod}+Mod1+n" = "exec ${binaries.browser-work-profile}";
            "${mod}+Shift+n" = "exec ${binaries.browser-private}";
            "${mod}+d" = "exec ${binaries.launcher}";

            "${mod}+z" = "focus child";
            "${mod}+Shift+minus" = "move to scratchpad";
            "${mod}+minus" = "scratchpad show";

            "${mod}+h" = "focus left";
            "${mod}+j" = "focus down";
            "${mod}+k" = "focus up";
            "${mod}+l" = "focus right";
            "${mod}+Shift+h" = "move left";
            "${mod}+Shift+j" = "move down";
            "${mod}+Shift+k" = "move up";
            "${mod}+Shift+l" = "move right";

            "${mod}+i" = "workspace prev_on_output";
            "${mod}+o" = "workspace next_on_output";
            "${mod}+Shift+i" = "focus output left";
            "${mod}+Shift+o" = "focus output right";

            "${mod}+v" = "split h";
            "${mod}+b" = "split v";
            "${mod}+Shift+s" = "sticky toggle";

            "XF86AudioPlay" = "exec ${binaries.playerctl} play-pause";
            "XF86AudioNext" = "exec ${binaries.playerctl} next";
            "XF86AudioPrev" = "exec ${binaries.playerctl} previous";

            "Print"       = "exec ${binaries.screenshot} -r";
            # "Print"       = "exec ${binaries.screenshot}";
            "Alt+Print"   = "exec ${binaries.screenshot} -w";
            # "Alt+Print"   = "exec ${binaries.screenshot} window";
            "Shift+Print" = "exec ${binaries.screenshot} -f";
            # "Shift+Print" = "exec ${binaries.screenshot} screen";
            "Control+Print" = "exec ${binaries.screenshot}";
          };
        };
      };
    };
}
