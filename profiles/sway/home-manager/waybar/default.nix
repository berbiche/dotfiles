{ config, lib, pkgs, ... }:

let
  margin = 5;
  layer = "top";
  width = 1200;
  height = 30;

  spacing = 8;

  custom-modules = import ./custom-modules.nix { inherit config lib pkgs; };

  top-bar = {
    inherit layer spacing;
    inherit height width;
    position = "top";
    margin-top = margin;
    margin-right = margin;
    margin-left = margin;
    # margin-bottom = margin;

    modules-left = [
      "sway/workspaces"
      "sway/mode"
    ];
    modules-center = [
      # "cpu"
      # "memory"
      "inhibitor"
      "clock"
      "custom/dark-mode"
      # "disk#1"
    ];
    modules-right = [
      "custom/do-not-disturb"
      "pulseaudio#volume"
      "pulseaudio#microphone"
      # "network"
      "backlight"
      "battery"
      # "custom/reboot"
      # "custom/shutdown"
      "tray"
    ];

    inherit (custom-modules) "custom/dark-mode" "custom/reboot" "custom/shutdown" "custom/do-not-disturb";

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

    "inhibitor" = {
      what = [ "idle" ];
      format = "{icon}";
      format-icons = {
        activated = "聯";
        deactivated = "輦";
      };
    };

    "tray" = {
      icon-size = 16;
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
      # format = "{icon} {percent:2}%";
      format = " {percent:2}%";
      format-icons = [ "ﯦ" "ﯧ" ];
      on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl set +5%";
      on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
    };

    "battery" = {
      interval = 30;
      # format = "{icon} {capacity:2}%{time}";
      format = "{icon} {capacity:2}%";
      format-time = " ({H}:{M:2})";
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

    "pulseaudio#volume" = {
      scroll-step = "10%";
      format = "{icon} {volume}%";
      format-source = " {volume}%";
      format-source-muted = " 0%";
      format-bluetooth = "{icon} {volume}%";
      format-bluetooth-muted = "婢 {icon}";
      format-muted = "婢 0%";
      format-icons = {
        # headphones = "";
        # hands-free = "";
        # headset = "";
        # phone = "";
        default = [
          # "婢"
          # ""
          ""
        ];
      };
      on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
    };

    "pulseaudio#microphone" = {
      scroll-step = "0%";
      format = "{format_source}";
      format-source = " {volume}%";
      format-source-muted = " 0%";
      on-scroll-up = "";
      on-scroll-down = "";
      on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
      on-click-right = "${config.lib.my.getScript "volume.sh"} mic-mute";
    };

  };

  bottom-bar = {
    inherit layer spacing;
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
      on-click-middle = "close";
      on-click-right = "minimize";
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

    settings = {
      inherit top-bar;
      # inherit bottom-bar;
    };
    style = ./style.css;
  };

  systemd.user.services.waybar = lib.mkIf config.programs.waybar.enable {
    # Temporary "fix" until https://github.com/Alexays/Waybar/issues/1205
    # is resolved
    Service.Environment = [ "PATH=${lib.makeBinPath [ "/run/current-system/sw" config.home.profileDirectory ]}" ];
    Install.WantedBy = lib.mkForce [ "sway-session.target" ];
  };
}
