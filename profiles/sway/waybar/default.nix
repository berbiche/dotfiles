{ config, lib, pkgs, ... }:

let
  spotify = pkgs.python3Packages.buildPythonApplication {
    name = "spotify.py";
    src = ./spotify.py;
    format = "other";
    doCheck = false;
    dontUnpack = true;
    strictDeps = false;
    buildInputs = with pkgs; [ gtk3 playerctl ];
    nativeBuildInputs = with pkgs; [ gobject-introspection wrapGAppsHook ];
    propagatedBuildInputs = [ pkgs.python3Packages.pygobject3 ];
    installPhase = ''
      install -Dm0755 $src $out/bin/spotify
    '';
  };

  margin = 5;
  layer = "bottom";

  top-bar = {
    inherit layer;
    position = "top";
    margin-top = margin;
    margin-right = margin;
    margin-left = margin;
    # margin-bottom = margin;

    modules-left = [
      "sway/workspaces"
      "custom/separator"
      "sway/mode"
      "custom/separator"
      "idle_inhibitor"
    ];
    modules-center = [
      "cpu"
      "custom/separator"
      "memory"
      "custom/separator"
      "clock"
      "custom/separator"
      "disk#1"
      "custom/separator"
      "battery"
    ];
    modules-right = [
      "tray"
      "custom/separator"
      "network"
      "custom/separator"
      "backlight"
      "custom/separator"
      "pulseaudio"
      "custom/separator"
      "custom/reboot"
      "custom/separator"
      "custom/shutdown"
    ];

    modules = {
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
        icon-size = 14;
        spacing = 10;
      };

      "clock" = {
        interval = 60;
        format = "{:%a %d %b %H:%M}";
        tooltip = true;
        tooltip-format = ''
          <big>{:%Y %B}</big>
          <tt><small>{calendar}</small></tt>
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
        format = "{icon} {capacity:2}%";
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

      "custom/reboot" = {
        format = "";
        tooltip = false;
        on-click = pkgs.writeShellScript "reboot.sh" ''
          ${pkgs.gnome3.zenity}/bin/zenity --question --text "Are you sure you want to reboot?" \
            --title 'Reboot?' \
            --window-icon warning \
            --timeout 10 \
            --height 100 --width 200 &
          pid=$!
          swaymsg "[pid=$pid] floating enable, focus"
          if wait $pid; then
            systemctl reboot
          fi
        '';
      };

      "custom/shutdown" = {
        format = "";
        tooltip = false;
        on-click = pkgs.writeShellScript "shutdown.sh" ''
          ${pkgs.gnome3.zenity}/bin/zenity --question --text "Are you sure you want to shutdown?" \
            --title 'Shutdown?' \
            --window-icon warning \
            --timeout 10 \
            --height 100 --width 200 &
          pid=$!
          swaymsg "[pid=$pid] floating enable, focus"
          if wait $pid; then
            systemctl poweroff
          fi
        '';
      };

      "custom/separator" = {
        format = "";
        tooltip = false;
	    };
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

    modules = {
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

      "custom/spotify" = rec {
        return-type = "json";
        format = " {}";
        restart-interval = 10;
        exec = "${spotify}/bin/spotify";
        on-click = "${pkgs.sway}/bin/swaymsg -q '[class=Spotify] focus'";
        on-click-right = "${pkgs.playerctl}/bin/playerctl play-pause --player=spotify";
        on-click-middle = on-click-right;
      };

      "custom/weather" = {
        interval = 1800;
        exec = pkgs.writeShellScript "weather.sh" ''
          ${pkgs.curl}/bin/curl -s 'https://wttr.in/?format="%C,+%t'
        '';
      };

      # "custom/separator" = {
      #   format = "";
      #   tooltip = false;
	    # };
    };
  };
in
{
  my.home = { config, ... }: {
    programs.waybar = {
      enable = true;
      systemd.enable = true;

      settings = [
        top-bar
        bottom-bar
      ];
      style = builtins.readFile ./style.css;
    };

    systemd.user.services.waybar = {
      Unit.X-Restart-Triggers = [ "${config.xdg.configFile."waybar/config".source}" ];
      Install.WantedBy = lib.mkForce [ "sway-session.target" ];
    };
  };
}
