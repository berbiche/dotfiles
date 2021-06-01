{ config, lib, pkgs, ... }:

{
  my.home = {
    home.packages = with pkgs; [ wlogout ];

    xdg.configFile."wlogout/layout".text = ''
      {
        "label" : "lock",
        "action" : "swaylock",
        "text" : "Lock",
        "keybind" : "l"
      }
      {
        "label" : "hibernate",
        "action" : "systemctl hibernate",
        "text" : "Hibernate",
        "keybind" : "h"
      }
      {
        "label" : "logout",
        "action" : "loginctl terminate-user $USER",
        "text" : "Logout",
        "keybind" : "K"
      }
      {
        "label" : "shutdown",
        "action" : "systemctl poweroff",
        "text" : "Shutdown",
        "keybind" : "H"
      }
      {
        "label" : "suspend",
        "action" : "systemctl suspend",
        "text" : "Suspend",
        "keybind" : "s"
      }
      {
        "label" : "reboot",
        "action" : "systemctl reboot",
        "text" : "Reboot",
        "keybind" : "r"
      }
    '';
  };
}
