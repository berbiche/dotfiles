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
    ./dunst.nix
    ./swaync
    # ./linux-notification-center.nix
    # ./mako.nix

    # Automatically changes the theme for my desktop based on the time
    # of day and controls the gamma and brightness
    ./gammastep.nix

    # Automatically lock my system after a set interval
    ./idle-service.nix

    # Automatically setup my displays based on a set of profiles
    ./kanshi.nix

    # Shows a prompt to run some root stuff like certain systemctl calls
    ./polkit.nix

    # rofi/Dmenu for Wayland, application runner that supports binaries
    # and desktop files
    # ./wofi.nix
    ./rofi.nix

    # Sway's lockscreen configuration
    ./swaylock.nix

    # User
    ./udiskie.nix

    # Daemon to expose Sway settings like the cursor package and size.
    # Required for proper scaling support of the cursor in XWayland apps
    # when the display is scaled.
    ./xsettingsd.nix

    # Logout menu that is displayed with a special keybind
    ./wlogout.nix
  ];

  # Disable reloading Sway on every change
  xdg.configFile."sway/config".onChange = lib.mkForce "";

  systemd.user.targets.sway-session = {
    Unit = {
      Description = "sway compositor session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };
  };

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Requires = [ "graphical-session-pre.target" ];
    };
  };

  programs.swaylock = {
    enable = true;
    imagePath = lib.mkDefault (config.xdg.userDirs.pictures + "/wallpaper/current");
  };

  programs.waybar.enable = true;
  programs.nwg-panel.enable = false;

  services.dunst.enable = false;
  services.sway-notification-center.enable = true;
}
