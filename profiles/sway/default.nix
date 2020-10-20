{ config, pkgs, ... }:

{
  imports = [
    ./sway-config
    ./waybar
  ];

  services.xserver.displayManager.defaultSession = "sway";

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];
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

    extraPackages = with pkgs; [ qt5.qtwayland ];

    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      # needs qt5.qtwayland in systemPackages
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      export _JAVA_AWT_WM_NONREPARENTING=1

      export XDG_CURRENT_DESKTOP=sway
    '';
  };

  my.home = { config, pkgs, lib, ... }: {
    imports = [
      ./kanshi.nix
      ./mako.nix
      ./swaylock.nix
      ./wlogout.nix
      ./wofi.nix
    ];

    home.packages = with pkgs; [
      # Audio software
      pavucontrol
      pamixer # control pulse audio volume in scripts

      libnotify # `notify-send` notifications to test mako
      dex # execute .desktop files
    ];

    systemd.user.targets.wayland-session.Unit = {
      Description = "Wayland compositor session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };

    # Copy the scripts folder
    home.file."scripts".source = "${
      # For the patchShebang phase
      pkgs.runCommandLocal "sway-scripts" {} ''
        cp -T -r ${./scripts} $out
      ''
    }";

    programs.swaylock = {
      enable = true;
      imageFolder = config.xdg.userDirs.pictures + "/wallpaper";
    };
  };
}
