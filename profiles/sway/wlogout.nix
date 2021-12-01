{ config, lib, pkgs, ... }:

{
  programs.wlogout.enable = true;

  programs.wlogout.layouts."layout" = [
    {
      label = "lock";
      action = "${pkgs.systemd}/bin/loginctl lock-session";
      text = "Lock";
      keybind = "l";
    }
    {
      label = "hibernate";
      action = "${pkgs.systemd}/bin/systemctl hibernate";
      text = "Hibernate";
      keybind = "h";
    }
    {
      label = "logout";
      action = "${pkgs.systemd}/bin/loginctl terminate-user $USER";
      text = "Logout";
      keybind = "K";
    }
    {
      label = "shutdown";
      action = "${pkgs.systemd}/bin/systemctl poweroff";
      text = "Shutdown";
      keybind = "H";
    }
    {
      label = "suspend";
      action = "${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
      text = "Suspend";
      keybind = "s";
    }
    {
      label = "reboot";
      action = "${pkgs.systemd}/bin/systemctl reboot";
      text = "Reboot";
      keybind = "r";
    }
  ];
}
