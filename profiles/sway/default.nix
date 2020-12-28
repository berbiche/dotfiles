{ config, pkgs, ... }:

{
  imports = [
    ./sway-config
    ./waybar
    ./libinput.nix
    ./screenshare.nix
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

    extraPackages = with pkgs; [ qt5.qtwayland ];

    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland

      # needs qt5.qtwayland in systemPackages
      #export QT_QPA_PLATFORM=wayland-egl
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      # Makes obs-studio unusably slow (more than 1 minute startup time)
      #export QT_WAYLAND_FORCE_DPI=physical

      # Enlightenment and stuff?
      export ELM_ENGINE=wayland_egl
      export ECORE_EVAS_ENGINE=wayland_egl

      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      export _JAVA_AWT_WM_NONREPARENTING=1

      export XDG_CURRENT_DESKTOP=sway

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

    # Copy the scripts folder
    home.file."scripts".source = let
      path = lib.makeBinPath (with pkgs; [
        gawk gnused jq wget
        pulseaudio # for pactl
        pamixer # volume control
        volnoti # show a popup notification for the volume level
        sway # for swaymsg
        wl-clipboard # wl-copy/wl-paste
        fzf # menu
        wofi # menu
        xdg-user-dirs # for the screenshot tool
        networkmanager # for nmcli
        notify-send_sh # from my overlays
        playerctl # to control mpris players
      ]);
    in "${
      # For the patchShebang phase
      pkgs.runCommandLocal "sway-scripts" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
        cp --no-preserve=mode -T -r "${./scripts}" $out
        chmod +x $out/*
        for i in $out/*; do
          wrapProgram $i --prefix PATH : ${path}
        done
      ''
    }";

    programs.swaylock = {
      enable = true;
      imageFolder = config.xdg.userDirs.pictures + "/wallpaper";
    };
  };
}
