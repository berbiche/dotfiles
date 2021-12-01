{ config, lib, pkgs, ... }:

{
  home.packages = [ pkgs.gammastep ];

  services.gammastep.enable = true;

  services.gammastep = {
    enable = true;
    tray = true;

    provider = "manual";
    latitude = config.my.location.latitude;
    longitude = config.my.location.longitude;

    temperature.day = 6500;
    temperature.night = 6500;
  };

  services.gammastep.settings = {
    general = {
      fade = 1;
      gamma-day = "0.8:0.7:0.8";
      gamma-night = 0.7;
      adjustment-method = "wayland";
    };
  };

  systemd.user.services.gammastep = {
    Unit = {
      X-Restart-Triggers = [
        "${config.xdg.configFile."gammastep/hooks/gtk-dark-mode".source}"
      ];
    };
    Install.WantedBy = lib.mkForce [ "sway-session.target" ];
  };

  xdg.configFile."gammastep/hooks/gtk-dark-mode".source =
    let
      xdg_data_dir = ''
        export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}''${XDG_DATA_DIRS:+':'}$XDG_DATA_DIRS"
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
}
