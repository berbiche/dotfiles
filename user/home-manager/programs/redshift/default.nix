{ config, lib, pkgs, ... }:

{
  home.packages = [ pkgs.redshift-wayland ];
  xdg.configFile."redshift/redshift.conf".source = ./redshift.conf;
}
