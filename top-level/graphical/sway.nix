{ config, lib, pkgs, ... }:

let
  url = rec {
    # Depends on Wayland 1.18.0 which isn't in nixos 20.03
    #rev = "5219af1f4f8edaadeb1e41053c27a420140cdc80";
    rev = "master";
    host = "https://github.com/colemickens/nixpkgs-wayland/archive";
    url = "${host}/${rev}.tar.gz";
  }.url;
  waylandOverlay = (import (builtins.fetchTarball url));
in
{
  nixpkgs.overlays = [ waylandOverlay ];

  programs.sway = {
    enable = true;

    wrapperFeatures = {
      # Fixes GTK applications under Sway
      gtk = true;
      # To run Sway with dbus-run-session
      base = true;
    };

    extraPackages = with pkgs; [
      xwayland

      brightnessctl

      swayidle
      swaylock
      swaybg

      gebaar-libinput  # libinput gestures utility
      wtype            # xdotool, but for wayland

      grim
      slurp
      wf-recorder      # wayland screenrecorder

      waybar
      mako
      volnoti
      kanshi
      wl-clipboard
      wdisplays

      # oblogout alternative
      wlogout


      wofi
      xfce.xfce4-appfinder

      # TODO: more steps required to use this?
      xdg-desktop-portal-wlr # xdg-desktop-portal backend for wlroots
    ];

    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      # needs qt5.qtwayland in systemPackages
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      export _JAVA_AWT_WM_NONREPARENTING=1
      # Fix "Firefox is already running, but not responding. To open..."
      export MOZ_DBUS_REMOTE=1
      export XDG_CURRENT_DESKTOP=sway
      export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

      systemctl --user import-environment
    '';
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    gtkUsePortal = true;
  };
  services.pipewire.enable = true;

  #programs.light.enable = true;

  # environment.systemPackages = with pkgs; [
  #   # other compositors/window-managers
  #   bspwc    # Wayland compositor based on BSPWM
  #   cage     # A Wayland kiosk (runs a single app fullscreen)
  #   wayfire   # 3D wayland compositor
  #   wf-config # wayfire config manager
  # ];
}
