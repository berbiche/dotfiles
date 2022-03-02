args@{ config, lib, pkgs, ... }:

let
  dconf = "${lib.getBin pkgs.dconf}/bin/dconf";
  latitude = args.osConfig.my.location.latitude or null;
  longitude = args.osConfig.my.location.longitude or null;
in
{
  services.darkman = {
    enable = true;

    settings.lat = lib.mkIf (latitude != null) latitude;
    settings.lng = lib.mkIf (longitude != null) longitude;

    darkModeScripts.gtk-theme = ''
      ${dconf} write /org/gnome/desktop/interface/gtk-theme "'${config.my.theme.dark}'"
    '';

    lightModeScripts.gtk-theme = ''
      ${dconf} write /org/gnome/desktop/interface/gtk-theme "'${config.my.theme.light}'"
    '';
  };

  systemd.user.services.darkman.Install.WantedBy = [ "sway-session.target" ];
}
