{ config, lib, pkgs, ... }:

let
  # Number at the start is used for ordering
  # https://github.com/Alexays/Waybar/blob/f233d27b782c04ef128e3d71ec32a0b2ce02df39/src/modules/sway/workspaces.cpp#L351-L357
  workspaces = {
    WS1 = "1:";      # browsing
    WS2 = "2:";      # school
    WS3 = "3:";      # dev
    WS4 = "4:";      # sysadmin
    WS5 = "5:";      # gaming
    WS6 = "6:";      # movie
    WS7 = "7:";      # social
    WS8 = "8";        # scratchpad
    WS9 = "9";        # scratchpad
    WS10 = "10";      # scratchpad
  };
in
{
  imports = [
    # i3/sway colors
    ./colors.nix

    # Automatically changes the theme for my desktop based on the time
    ./darkman.nix

    # Expose Gnome/GTK settings automatically to GTK/x11 applications.
    # Required for proper scaling support of the cursor in XWayland apps
    # when the display is scaled.
    ./gsettingsd.nix

    # Generic notification daemon configuration
    ./notifications.nix
    # Specific notification daemon configuration
    ./dunst.nix
    ./linux-notification-center.nix
    ./swaync

    # Shows a prompt to run some root stuff like certain systemctl calls
    ./polkit.nix

    # Show a prompt to mount usb disks
    ./udiskie.nix

    # Application runner
    ./ulauncher.nix
  ];

  options.profiles.i3-sway.workspaces = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
  };

  options.profiles.i3-sway.modifier = lib.mkOption {
    type = lib.types.str;
    default = "Mod4";
  };

  config = {
    profiles.i3-sway.workspaces = lib.mkDefault workspaces;

    xsession.windowManager.i3.config.modifier = config.profiles.i3-sway.modifier;
    xsession.windowManager.i3.config.floating.modifier = config.profiles.i3-sway.modifier;
    wayland.windowManager.sway.config.modifier = config.profiles.i3-sway.modifier;
    wayland.windowManager.sway.config.floating.modifier = config.profiles.i3-sway.modifier;
  };
}
