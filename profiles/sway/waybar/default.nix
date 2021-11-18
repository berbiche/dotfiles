{ ... }:

{
  my.home = { config, lib, pkgs, ... }: let
    margin = 5;
    layer = "top";
    width = 1200;

    custom-modules = import ./custom-modules.nix { inherit config lib pkgs; };

    top-bar = {
      inherit layer;
      position = "top";
      width = width;
      margin-top = margin;
      margin-right = margin;
      margin-left = margin;
      # margin-bottom = margin;

      spacing = 8;

      modules-left = [
        "sway/workspaces"
        "sway/mode"
      ];
      modules-center = [
        # "cpu"
        # "custom/separator"
        # "memory"
        # "custom/separator"
        "idle_inhibitor"
        "clock"
        "custom/dark-mode"
        # "custom/separator"
        # "disk#1"
      ];
      modules-right = [
        # "custom/separator"
        # "network"
        "pulseaudio"
        "backlight"
        "battery"
        "custom/reboot"
        "custom/shutdown"
        "tray"
      ];

      inherit (custom-modules) "custom/separator" "custom/dark-mode" "custom/reboot" "custom/shutdown" "custom/do-not-disturb";

      "sway/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
        format = "{name} {icon}";
        format-icons = {
          # "urgent" = "";
          "urgent" = "";
          # "focused" = "";
          "focused" = "";
          # "default" = "";
          "default" = "";
        };
      };

      "sway/mode" = {
        format = "<span style=\"italic\">{}</span>";
      };

      "idle_inhibitor" = {
        format = "{icon}";
        format-icons = {
          activated = "聯";
          deactivated = "輦";
        };
      };

      "tray" = {
        icon-size = 12;
        spacing = 8;
      };

      "clock" = {
        interval = 60;
        format = "{:%a %d %b %H:%M}";
        tooltip = true;
        align = 1.0;
        tooltip-format = ''
          <big>{:%Y %B}</big>
          <span font_desc="Anonymice Nerd Font" size='large'>{calendar}</span>
        '';
      };

      "cpu" = {
        interval = 1;
        format = " {usage:2}%";
        # format = " {usage:2}%";
      };

      "memory" = {
        interval = 5;
        format = " {:2}%";
      };

      "backlight" = {
        device = "intel_backlight";
        format = "{icon} {percent:2}%";
        format-icons = [ "ﯦ" "ﯧ" ];
        on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl set +5%";
        on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
      };

      "battery" = {
        interval = 30;
        format = "{icon} {capacity:2}% ({time})";
        format-time = "{H}:{M}";
        format-icons = [ "" "" "" "" "" ];
        states = {
          good = 95;
          warning = 25;
          critical = 10;
        };
      };

      "disk#1" = {
        interval = 5;
        format = "  {percentage_used:2}%";
        path = "/";
      };

      "network" = {
        # interface = "wlp2s0"; # (Optional) To force the use of this interface
        format-wifi = "{icon} {ipaddr}/{essid}";
        format-ethernet = "{icon} {ipaddr}/{cidr}";
        format-icons = {
          #"wifi" = [""; "" ;""];
          wifi = [ "" ];
          ethernet = [ "" ];
          disconnected = [ "" ];
        };
        tooltip = "{essid} {ipaddr}/{cidr}";
        on-click = "network-manager";
      };

      "pulseaudio" = {
        scroll-step = "10%";
        format = "{icon} {volume}% {format_source}";
        format-source = " {volume}%";
        format-source-muted = "";
        #format-bluetooth = " {volume}";
        format-bluetooth = "{icon} {volume}% {format_source}";
        format-bluetooth-muted = " {icon} {format_source}";
        format-muted = "婢 {format_source}";
        format-icons = {
          headphones = "";
          headset = "";
          phone = "";
          default = [
            ""
            ""
            ""
          ];
        };
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
      };

    };

    bottom-bar = {
      inherit layer;
      position = "bottom";
      # margin-top = margin;
      margin-right = margin;
      margin-left = margin;
      margin-bottom = margin;

      modules-left = [ "custom/weather" "wlr/taskbar" ];
      # modules-center = [ "sway/window" ];
      modules-right = [ "custom/spotify" ];

      inherit (custom-modules) "custom/weather" "custom/spotify";

      "wlr/taskbar" = {
        all-outputs = false;
        format = "{icon} {title:.18}..";
        # icon-theme = "DarK-svg";
        icon-size = 12;
        on-click = "activate";
        on-middle-click = "close";
        on-right-click = "minimize";
      };

      # "sway/window" = {
      #   max-length = 120;
      # };
    };
  in
  {
    programs.waybar = {
      package = pkgs.nixpkgs-wayland.waybar;

      systemd.enable = true;

      settings = [
        top-bar
        # bottom-bar
      ];
      style = builtins.readFile ./style.css;
    };

    systemd.user.services.waybar = lib.mkIf config.programs.waybar.enable {
      # Temporary "fix" until https://github.com/Alexays/Waybar/issues/1205
      # is resolved
      Service.Environment = [ "PATH=/run/current-system/sw/bin" ];
    };
  };
}
