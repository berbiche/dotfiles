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

  # TODO: See if this is necessary to be used with home-manager's Sway configuration
  # FIXME: Duplicate code
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

      grim
      slurp
      wf-recorder      # wayland screenrecorder

      waybar
      mako
      volnoti
      wl-clipboard
      wdisplays

      # oblogout alternative
      wlogout

      wofi
      xfce.xfce4-appfinder

      xdg-desktop-portal-wlr # xdg-desktop-portal backend for wlroots

      qt5.qtwayland
    ];

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

  home-manager.users.${config.my.username} = { config, pkgs, ... }: {
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
    ]

    # Copy the scripts folder
    home.file."scripts" = {
      source = ../../scripts;
      recursive = false; # we want the folder symlinked, not its files
    };

    programs.swaylock = {
      enable = true;
      imageFolder = config.xdg.userDirs.pictures + "/wallpaper";
    };
  };
}
