{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ sway swayidle ];
  xdg.configFile."sway/config".source = ./config;
  xdg.configFile."sway/window-rules.d".source = ./window-rules.d;
  xdg.configFile."sway/config.d".source = ./config.d;

  systemd.user.targets.sway-session = {
    description = "sway compositor session";
    documentation = "man:systemd.special(7)";
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };
}
