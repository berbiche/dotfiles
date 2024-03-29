{ config, lib, pkgs, ... }:

{
  imports = [
    # My actual Sway configuration (keybindings, etc.)
    ./sway.nix

    # Bar that displays active workspaces, running apps, a calendar, etc.
    ./waybar

    # Waybar with a Gnome-like look. Lacks all the native modules Waybar has.
    ./nwg-panel

    # Displays a notification for volume/microphone/brightness changes
    # with the script volume.sh
    ./avizo.nix

    # Displays notification
    ./mako.nix

    # Automatically changes the theme for my desktop based on the time
    # of day and controls the gamma and brightness
    ./gammastep.nix

    # Automatically lock my system after a set interval
    ./idle-service.nix

    # Automatically setup my displays based on a set of profiles
    ./kanshi.nix

    # rofi/Dmenu for Wayland, application runner that supports binaries
    # and desktop files
    # ./wofi.nix
    ./rofi.nix

    # Sway's lockscreen configuration
    ./swaylock.nix
    ./gtklock.nix

    # Logout menu that is displayed with a special keybind
    ./wlogout.nix
    ./wlogoutbar.nix
  ];

  # Disable reloading Sway on every change
  xdg.configFile."sway/config".onChange = lib.mkForce "";

  systemd.user.targets.sway-session = {
    Unit = {
      Description = "sway compositor session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" "tray.target" ];
      Requires = [ "graphical-session-pre.target" ];
    };
  };

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Documentation = [ "man:systemd.special(7)" ];
      Requires = [ "graphical-session-pre.target" ];
    };
  };

  programs.swaylock = {
    enable = true;
    imagePath = lib.mkDefault (config.xdg.userDirs.pictures + "/wallpaper/current");
  };

  programs.waybar.enable = true;
  programs.nwg-panel.enable = false;

  # systemd.user.services.dunst.Service.UnsetEnvironment = [ "DISPLAY" ];

  home.packages = [ pkgs.flameshot ];
}
