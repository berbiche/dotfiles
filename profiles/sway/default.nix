{ config, lib, pkgs, ... }:

{
  imports = [
    # Trackpad gestures handling to allow MacOS-like workspace switching
    ./libinput.nix

    # Configuration that enables screensharing in Firefox and other programs
    ./screenshare.nix

    # ./gnome-session.nix
  ];

  my.home = { imports = [ ./home-manager ]; };

  services.xserver.displayManager.defaultSession = "sway";

  profiles.sway.libinput.enable = true;

  # I don't use the Sway Home Manager module since it does not expose
  # the session to my login manager
  my.home.wayland.windowManager.sway.package = lib.mkForce null;

  programs.sway = {
    enable = true;

    wrapperFeatures = {
      # Fixes GTK applications under Sway
      gtk = true;
      # To run Sway with dbus-run-session and other stuff
      # (dbus-run-session is unneeded since dbus is socket activated in NixOS now)
      base = true;
    };

    extraPackages = with pkgs; [ qt5.qtwayland ];

    extraOptions = [ "--verbose" ];

    extraSessionCommands = ''
      # needs qt5.qtwayland in extraPackages
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"

      # Steam and other stuff
      # Games that will not run in Wayland must be started
      # with SDL_VIDEODRIVER=x11
      export SDL_VIDEODRIVER=wayland

      # Enlightenment and stuff?
      export ELM_ENGINE=wayland
      export ECORE_EVAS_ENGINE=wayland

      # Fix for some Java AWT applications (e.g. Android Studio)
      export _JAVA_AWT_WM_NONREPARENTING=1

      # Workaround xdg-desktop-portal not having the right XDG_CURRENT_DESKTOP
      export XDG_CURRENT_DESKTOP=sway XDG_SESSION_TYPE=wayland XDG_SESSION_DESKTOP=sway

      # Export required DBUS variables for XDG desktop portals
      # if [ ! -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
        ${pkgs.dbus}/bin/dbus-update-activation-environment XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP
      # fi
    '';
  };

  # Displays keys being taped on the screen
  programs.wshowkeys.enable = true;
}
