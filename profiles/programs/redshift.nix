{ config, lib, pkgs, ... }:

let
  # Requires an impure build
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux;
in
lib.optionalAttrs isLinux {
  # Requires nixpkgs-wayland overlay
  services.redshift = {
    enable = true;
    package = pkgs.redshift-wayland;
    # Some options cannot be configured through the command line (gamma-day, gamma-night, fade)
    extraOptions = [ "-c ${config.xdg.configHome}/redshift/redshift.conf" ];
    tray = true;
    provider = "geoclue2";
  };

  xdg.configFile."redshift/redshift.conf".text = ''
    [redshift]
    temp-day=6500
    temp-night=4000

    fade=1

    gamma-day=0.8:0.7:0.8
    gamma-night=0.6

    location-provider=geoclue2

    adjustment-method=wayland
  '';
}
