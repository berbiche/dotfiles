{ config, lib, options, pkgs, ... }:

let
  swayConfig = lib.myLib.callWithDefaults ./sway-config/config.nix { inherit config options; };
in
{
  home.packages = with pkgs; [
    qt5.qtwayland
    wl-clipboard
    wdisplays
    brightnessctl
    grim
    slurp
    swaylock
  ];

  wayland.windowManager.sway = {
    enable = true;

    inherit (swayConfig) config extraConfig;

    wrapperFeatures = {
      # Fixes GTK applications under Sway
      gtk = true;
      # To run Sway with dbus-run-session and other stuff
      # (dbus-run-session is unneeded since dbus is socket activated in NixOS now)
      base = true;
    };

    # We handle the on-startup ourselves now
    systemdIntegration = false;
    xwayland = true;

    extraOptions = [ "--verbose" ];

    extraSessionCommands = ''
      # needs `qt5.qtwayland` in packages
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

      # Run Firefox with the Wayland backend
      export MOZ_ENABLE_WAYLAND = "1";

      # Use GTK portal for the file picker and other things
      export GTK_USE_PORTAL=1

      # TODO: remove once gnome-keyring exports SSH_AUTH_SOCK correctly
      : ''${XDG_RUNTIME_DIR=/run/user/$(id -u)}
      if [ -S  "''${XDG_RUNTIME_DIR}/keyring/ssh" ]; then
        export SSH_AUTH_SOCK="''${XDG_RUNTIME_DIR}/keyring/ssh"
      fi
    '';
  };
}
