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
    settings.usegeoclue = latitude == null || longitude == null;

    darkModeScripts.gtk-theme = ''
      # ${dconf} write /org/gnome/desktop/interface/gtk-theme "'${config.my.theme.dark}'"
      ${dconf} write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    '';

    lightModeScripts.gtk-theme = ''
      # ${dconf} write /org/gnome/desktop/interface/gtk-theme "'${config.my.theme.light}'"
      ${dconf} write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
    '';
  };
}
