{ config, lib, pkgs, ... }:

{
  my.home = { config, ... }: {
    home.packages = [ pkgs.gammastep ];

    systemd.user.services.gammastep = {
      Unit = {
        Description = "Display colour temperature adjustment";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        X-Restart-Triggers = [
          "${config.xdg.configFile."gammastep/config.ini".source}"
          "${config.xdg.configFile."gammastep/hooks/gtk-dark-mode".source}"
        ];
      };
      Service = {
        ExecStart = "${pkgs.gammastep}/bin/gammastep-indicator";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "sway-session.target" ];
    };

    xdg.configFile."gammastep/config.ini".text = ''
      [general]
      temp-day=6500
      temp-night=4000
      fade=1
      gamma-day=0.8:0.7:0.8
      gamma-night=0.6
      location-provider=manual
      adjustment-method=wayland

      [manual]
      lat=${lib.strings.floatToString config.my.location.latitude}
      lon=-${lib.strings.floatToString config.my.location.longitude}
    '';

    xdg.configFile."gammastep/hooks/gtk-dark-mode".source =
      let
        xdg_data_dir = ''
          export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}''${XDG_DATA_DIRS:+:}$XDG_DATA_DIRS"
        '';
        gsettings = "${pkgs.glib.bin}/bin/gsettings";
      in
      pkgs.writeShellScript "gtk-dark-mode" ''
        ${xdg_data_dir}
        notify() {
            ${pkgs.coreutils}/bin/timeout 5 ${pkgs.libnotify}/bin/notify-send "Gammastep" "Changing to $1 theme"
        }
        case "$1" in
          period-changed)
            case "$3" in
              night)
                notify night
                ${gsettings} set org.gnome.desktop.interface gtk-theme ${config.my.theme.dark}
                ;;
              daytime)
                notify day
                ${gsettings} set org.gnome.desktop.interface gtk-theme ${config.my.theme.light}
                ;;
              transition)
                if [ "$2" = "none" ]; then
                  notify night
                  ${gsettings} set org.gnome.desktop.interface gtk-theme ${config.my.theme.dark}
                fi
                ;;
            esac
            ;;
        esac
      '';
  };
}
