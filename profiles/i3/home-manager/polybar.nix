{ config, lib, pkgs, ... }:

let
  height = 30;
  margin = 5;
  border = 1;
in
{
  systemd.user.services.polybar = lib.mkIf (config.services.polybar.enable) {
    Unit.ConditionEnvironment = [ "XDG_CURRENT_DESKTOP=none+i3" ];
    Install.WantedBy = [ "x11-session.target" ];
  };

  services.polybar = {
    enable = true;
    package = pkgs.polybar.override { i3GapsSupport = true; };

    # script = "${pkgs.bash}/bin/bash -lc 'polybar --reload spacer & polybar --reload main &'";
    script = "${pkgs.bash}/bin/bash -lc 'polybar --reload main &'";

    config = {
      "settings" = {
        screenchange-reload = true;
      };

      "global/wm" = {
        margin-top = 0;
        margin-bottom = 0;
      };

      # Blank spacer bar because i3-gaps will not position polybar in the center
      # "bar/spacer" = {
      #   height = height + (margin * 2) + (border * 2);
      #   width = "100%";
      #   background = "#00000000";
      #   foreground = "#00000000";
      #   modules-center = "time";
      # };

      "bar/main" = {
        enable-ipc = "true";
        height = height;

        # Yes, this is a static hardcoded monitor output, but I only use
        # X11 on a specific pc with a static configuration.
        monitor = "DP-4";
        monitor-fallback = "";

        # Don't make i3 aware of the bar (requires fake transparent spacer bar)
        # This is required or else the x offset is ignored and the left side of the
        # bar is stuck to the side of the monitor, ruining the floating effect
        override-redirect = true;

        # Put polybar at the bottom of the stack (behind other windows)
        # This is needed so that things like full screen apps, floating apps
        # or i3-nagbar get rendered on top of polybar
        wm-restack = "i3";

        width = "1200";
        offset-x = "50%:-600";
        offset-y = margin;

        border-size = border;
        border-color = "#FFF";

        # Completely disable underlines
        line-size = 1;

        # Radius disabled because the systray ignores it and it looks bad
        # radius = 4;

        tray-position = "right";
        tray-detached = false;
        tray-maxsize = 16;

        padding = 3;

        # font-N = <fontconfig pattern>;<vertical offset>
        # The vertical offset is very important because polybar
        # renders the font too high which makes it look like there
        # is padding/margin at the bottom of the bar. We need a y
        # offset to make the text render lower, a.k.a. "centered"
        font-0 = "Noto Sans:size=10;3";
        font-1 = "Noto Sans:size=10:style=Bold;3";
        font-2 = "FontAwesome:pixelsize=10;3";
        # font-3 = "Font Awesome 5 Free Regular:pixelsize=10;3";
        # font-4 = "Font Awesome 5 Free Solid:pixelsize=10;3";
        # font-5 = "Font Awesome 5 Brands:pixelsize=10;3";

        modules-left = "i3";
        modules-center = "time";
        modules-right = "pulseaudio";

        # Switch i3 workspaces by scrolling on the entire bar
        # scroll-up = "#i3.prev";
        # scroll-down = "#i3.next";
      };

      "module/i3" = {
        type = "internal/i3";
        strip-wsnumbers = "true";
        enable-click = "true";
        reverse-scroll = "false";

        label-focused-padding = 1;
        label-visible-padding = 1;
        label-unfocused-padding = 1;
        label-urgent-padding = 1;

        # label-focused-background = config.my.theme.color2;
        # label-visible-background = config.my.theme.color2;
        # label-unfocused-background = config.my.theme.color0;
        # label-urgent-background = config.my.theme.colorA;

        # https://github.com/polybar/polybar/issues/847
        # >This is because the default label for the workspaces is %icon% %name%,
        # and because you did not define the icons, the label now has an extra
        # space on the left. You can solve this by setting following in your i3 module:
        # label-focused = "%name%";
        # label-unfocused = "%name%";
        # label-visible = "%name%";
        # label-urgent = "%name%";

        # only show workspaces on the current monitor
        pin-workspaces = false;
      };

      "module/cpu" = {
        type = "internal/cpu";
        interval = 2;
        format-prefix = " ";
        format-padding = 2;
        label = "%percentage%%";
      };

      "module/memory" = {
        type = "internal/memory";
        interval = 2;
        format-padding = 2;
        format-prefix = " ";
        label = "%percentage_used%%";
      };

      "module/eth" = {
        type = "internal/network";
        # interface = config.my.wiredInterface;
        interval = 3;

        format-connected-prefix = " ";
        label-connected = "%local_ip%";

        format-disconnected = "";
        # ;format-disconnected = <label-disconnected>
        # ;label-disconnected = %ifname% disconnected
        # ;label-disconnected-color1 = ${colors.color1-alt}
      };

      "module/time" = {
        type = "internal/date";
        interval = 10;
        format-padding = 3;

        time = "%H:%M";
        date = "%A %d %b";

        label = "%date%, %time%";
        label-padding = 2;

        # Bold font for date
        # This font is defined as font-1 but we actually need to say font = 2 here
        label-font = 2;
      };

      "module/pulseaudio" = {
        type = "internal/alsa";
        master-mixer = "Master";
        # headphone-id = 9;
        format-volume-padding = 2;
        format-muted-padding = 2;
        label-muted = "婢 Mute";
        ramp-volume-0 = "";
        ramp-volume-1 = "";
        ramp-volume-2 = "";

        format-volume-margin = 2;
        format-volume = "<ramp-volume> <label-volume>";
        label-volume = "%percentage%%";
        use-ui-max = false;
        interval = 5;
      };

      "module/powermenu" = {
        type = "custom/menu";

        expand-right = true;

        format-spacing = 1;
        format-margin = 0;
        format-padding = 2;

        label-open = "";
        label-close = "";
        label-separator = "|";

        #; reboot
        menu-0-1 = "";
        menu-0-1-exec = "menu-open-2";
        #; poweroff
        menu-0-2 = "";
        menu-0-2-exec = "menu-open-3";
        #; logout
        menu-0-0 = "";
        menu-0-0-exec = "menu-open-1";

        menu-2-0 = "";
        menu-2-0-exec = "reboot";

        menu-3-0 = "";
        menu-3-0-exec = "poweroff";

        menu-1-0 = "";
        menu-1-0-exec = "";

      };
    };
  };
}
