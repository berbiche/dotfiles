{ config, lib, pkgs, ... }:

{
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    gtkUsePortal = true;
  };
  services.pipewire.enable = true;

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

      # Disable this as a test
      # export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

      # Second test
      # systemctl --user import-environment
    '';
  };
}
