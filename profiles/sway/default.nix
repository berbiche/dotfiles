{ config, pkgs, ... }:

let
  homeImports = [
    # My actual Sway configuration (keybindings, etc.)
    ./sway-config

    # Bar that displays active workspaces, running apps, a calendar, etc.
    ./waybar

    # Waybar with a Gnome-like look. Lacks all the native modules Waybar has.
    ./nwg-panel

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

    # Notification daemon
    # ./linux-notification-center.nix

    # Notification daemon
    # ./mako.nix

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
in
{
  imports = [
    # Trackpad gestures handling to allow MacOS-like workspace switching
    ./libinput.nix

    # Configuration that enables screensharing in Firefox and other programs
    ./screenshare.nix

    # ./gnome-session.nix
  ];

  services.xserver.displayManager.defaultSession = "sway";

  profiles.sway.libinput.enable = true;

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

      # TODO: remove once gnome-keyring exports SSH_AUTH_SOCK correctly
      : ''${XDG_RUNTIME_DIR=/run/user/$(id -u)}
      if [ -S  "''${XDG_RUNTIME_DIR}/keyring/ssh" ] then
        export SSH_AUTH_SOCK=''${XDG_RUNTIME_DIR}/keyring/ssh
      fi
    '';
  };

  # Displays keys being taped on the screen
  programs.wshowkeys.enable = true;

  my.home = { config, pkgs, lib, ... }: {
    imports = homeImports;

    # Disable reloading Sway on every change
    xdg.configFile."sway/config".onChange = lib.mkForce "";

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
