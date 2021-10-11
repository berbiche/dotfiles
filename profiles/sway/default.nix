{ config, pkgs, ... }:

{
  imports = [
    # My actual Sway configuration (keybindings, etc.)
    ./sway-config

    # Bar that displays active workspaces, running apps, a calendar, etc.
    ./waybar

    # Waybar with a Gnome-like look. Lacks all the native modules Waybar has.
    ./nwg-panel

    # No longer needed since I use avizo
    # ./eww

    # Displays a notification for volume/microphone/brightness changes
    # with the script volume.sh
    ./avizo.nix

    # Displays notification
    ./dunst.nix

    # Automatically changes the theme for my desktop based on the time
    # of day and controls the gamma and brightness
    ./gammastep.nix

    # Automatically lock my system after a set interval
    ./idle-service.nix

    # Automatically setup my displays based on a set of profiles
    ./kanshi.nix

    # Trackpad gestures handling to allow MacOS-like workspace switching
    ./libinput.nix

    # Notification daemon
    # ./linux-notification-center.nix

    # Notification daemon
    # ./mako.nix

    # Shows a prompt to run some root stuff like certain systemctl calls
    ./polkit.nix

    # Configuration that enables screensharing in Firefox and other programs
    ./screenshare.nix

    # Sway's lockscreen configuration
    ./swaylock.nix

    # User
    ./udiskie.nix

    # Avizo but can only show volume level
    # ./volnoti.nix

    # Logout menu that is displayed with a special keybind
    ./wlogout.nix

    # Like Avizo but much simpler and no longer needed
    # ./wob.nix

    # rofi/Dmenu for Wayland, application runner that supports binaries
    # and desktop files
    ./wofi.nix

    # Daemon to expose Sway settings like the cursor package and size.
    # Required for proper scaling support of the cursor in XWayland apps
    # when the display is scaled.
    ./xsettingsd.nix

    # ./gnome-session.nix
  ];

  services.xserver.displayManager.defaultSession = "sway";

  # I don't use the Sway Home Manager module since it does not expose
  # the session to my login manager
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
      # needs qt5.qtwayland in systemPackages
      export QT_QPA_PLATFORM=wayland-egl
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"

      # Allow Steam games to run under XWayland
      export SDL_VIDEODRIVER=x11

      # Enlightenment and stuff?
      export ELM_ENGINE=wayland_egl
      export ECORE_EVAS_ENGINE=wayland_egl

      # Fix for some Java AWT applications (e.g. Android Studio)
      export _JAVA_AWT_WM_NONREPARENTING=1

      # TODO: remove once gnome-keyring exports SSH_AUTH_SOCK correctly
      export SSH_AUTH_SOCK=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/keyring/ssh

      # Breaks FZF keybindings for some reason
      # [ -f /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh ] && \
      #   . /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh
    '';
  };

  # Displays keys being taped on the screen
  programs.wshowkeys.enable = true;

  my.home = { config, pkgs, lib, ... }: {
    # Disable reloading Sway on every change
    xdg.configFile."sway/config".onChange = lib.mkForce "";

    # systemd.user.targets.wayland-session.Unit = {
    #   Description = "Wayland compositor session";
    #   Documentation = [ "man:systemd.special(7)" ];
    #   BindsTo = [ "graphical-session.target" ];
    #   Wants = [ "graphical-session-pre.target" ];
    #   After = [ "graphical-session-pre.target" ];
    # };

    systemd.user.targets.sway-session.Unit = {
      Description = "sway compositor session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };

    programs.swaylock = {
      enable = true;
      imageFolder = config.xdg.userDirs.pictures + "/wallpaper";
    };

    programs.waybar.enable = true;
    programs.nwg-panel.enable = false;
  };
}
