{ config, pkgs, ... }:

{
  imports = [
    ./sway-config
    ./waybar
    ./libinput.nix
    ./screenshare.nix
    ./polkit.nix
    ./xsettingsd.nix
  ];

  services.xserver.displayManager.defaultSession = "sway";

  programs.sway = {
    enable = true;

    wrapperFeatures = {
      # Fixes GTK applications under Sway
      gtk = true;
      # To run Sway with dbus-run-session and other stuff
      # (dbus-run-session is unneeded since dbus is socket activated in NixOS now)
      base = true;
    };

    extraPackages = with pkgs; [ qt5.qtwayland cage ];

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

      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      export _JAVA_AWT_WM_NONREPARENTING=1

      # TODO: remove once gnome-keyring exports SSH_AUTH_SOCK correctly
      export SSH_AUTH_SOCK=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/keyring/ssh
    '';
  };

  # Doesn't work
  security.pam.services.waylock = {};

  my.home = { config, pkgs, lib, ... }: {
    imports = [
      ./kanshi.nix
      # ./mako.nix
      ./udiskie.nix
      ./linux-notification-center.nix
      ./swaylock.nix
      ./wlogout.nix
      ./wofi.nix
      ./gammastep.nix
    ];

    # Disable reloading Sway on every change
    xdg.configFile."sway/config".onChange = lib.mkForce "";

    systemd.user.targets.wayland-session.Unit = {
      Description = "Wayland compositor session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };

    systemd.user.targets.sway-session.Unit = {
      Description = "sway compositor session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = lib.mkForce [ "wayland-session.target" ];
      Wants = lib.mkForce [ "wayland-session.target" ];
      After = lib.mkForce [ "wayland-session.target" ];
    };


    programs.swaylock = {
      enable = true;
      imageFolder = config.xdg.userDirs.pictures + "/wallpaper";
    };
  };
}
