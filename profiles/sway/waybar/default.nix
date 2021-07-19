{ config, lib, pkgs, inputs, ... }:

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
      "custom/separator"
      "custom/dark-mode"
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

      "custom/dark-mode" =  let
        awk = "${pkgs.gawk}/bin/awk";
        gsettings = "${pkgs.glib.bin}/bin/gsettings";
        stdbuf = "${pkgs.coreutils}/bin/stdbuf";
        escape = x: ''"${lib.escape [ ''"'' ] x}"'';
        darkMode = builtins.toJSON {
          text = "Dark";
          alt = "dark";
          tooltip = "Toggle light theme";
          class = "dark";
        };
        lightMode = builtins.toJSON {
          text = "Light";
          alt = "light";
          tooltip = "Toggle dark theme";
          class = "light";
        };
        xdg_data_dir = ''
          export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}''${XDG_DATA_DIRS:+:}$XDG_DATA_DIRS"
        '';
      in {
        return-type = "json";
        format = "{icon}";
        format-icons = {
          light = ""; # fontawesome.com/cheatsheet sun f185
          dark = ""; # fontawesome.com/cheatsheet moon f186
        };
        exec = pkgs.writeShellScript "waybar-custom-dark-mode" ''
          ${xdg_data_dir}
          if [[ "$(${gsettings} get org.gnome.desktop.interface gtk-theme)" = "'Adwaita'" ]]; then
            echo ${lib.escapeShellArg lightMode}
          else
            echo ${lib.escapeShellArg darkMode}
          fi
          ${gsettings} monitor org.gnome.desktop.interface gtk-theme | \
            ${stdbuf} -o0 ${awk} '{
              if ($2 ~ /'\'''Adwaita'\'''/) {
                print ${escape lightMode}
              }
              else {
                print ${escape darkMode}
              }
            }'
            # ${pkgs.jq}/bin/jq --unbuffered --compact-output
        '';
        on-click = pkgs.writeShellScript "waybar-custom-dark-mode-on-click" ''
          ${xdg_data_dir}
          if [[ "$(${gsettings} get org.gnome.desktop.interface gtk-theme)" = "'Adwaita'" ]]; then
            ${gsettings} set org.gnome.desktop.interface gtk-theme Adwaita-dark
          else
            ${gsettings} set org.gnome.desktop.interface gtk-theme Adwaita
          fi
        '';
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
      package = pkgs.nixpkgs-wayland.waybar;

      systemd.enable = true;

      settings = [
        top-bar
        bottom-bar
      ];
      style = builtins.readFile ./style.css;
    };

    systemd.user.services.waybar = lib.mkIf config.programs.waybar.enable {
      Unit.X-Restart-Triggers = [ "${config.xdg.configFile."waybar/config".source}" ];
    };
  };
}
