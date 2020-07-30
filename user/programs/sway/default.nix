{ config, lib, pkgs, ... }:

let
  swayConfig = pkgs.callWithDefaults ./config.nix { inherit config; };
in
{
  home.packages = with pkgs; [
    brightnessctl

    swaylock

    grim
    slurp
    wf-recorder      # wayland screenrecorder

    waybar
    mako
    kanshi
    wl-clipboard
    wdisplays

    wofi

    # TODO: more steps required to use this?
    xdg-desktop-portal-wlr # xdg-desktop-portal backend for wlroots
    qt5.qtwayland
  ];

  wayland.windowManager.sway = {
    enable = true;
    # The package is the one from the nixpkgs-wayland overlay
    # package = lib.hiPrio pkgs.sway;

    # For the sway-session.target
    systemdIntegration = true;

    wrapperFeatures = {
      # Fixes GTK applications under Sway
      gtk = true;
      # To run Sway with dbus-run-session
      base = true;
    };

    xwayland = true;

    inherit (swayConfig) config extraConfig;

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

  # Idle service
  systemd.user.services.sway-idle =
    let
      swaylock = "${pkgs.swaylock}/bin/swaylock";
      swayidle = "${pkgs.swayidle}/bin/swayidle";
      swaymsg  = "${pkgs.sway}/bin/swaymsg";
    in
      {
        Unit = {
          Description = "Idle manager for Wayland";
          Documentation = "man:swayidle(1)";
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          Type = "simple";
          Restart = "always";
          RestartSec = "1sec";
          ExecStart = ''
            ${swayidle} -w \
                timeout 300  "${swaylock} -f" \
                timeout 600  "${swaymsg} 'output * dpms off'" \
                resume       "${swaymsg} 'output * dpms on'" \
                before-sleep "${swaylock} -f"
          '';
        };
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
      };

  systemd.user.services.kanshi = {
    Unit = {
      Description = "Kanshi output autoconfig";
      Documentation = "man:kanshi(1)";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.kanshi}/bin/kanshi";
      Restart = "always";
      RestartSec = 5;
    };
    Install.WantedBy = [ "sway-session.target" ];
  };

  systemd.user.services.volnoti = {
    Unit = {
      Description = "Lightweight volume notification daemon";
      Requisite = [ "dbus.service" ];
      After = [ "dbus.service" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "dbus";
      BusName = "uk.ac.cam.db538.volume-notification";
      ExecStart = "${pkgs.volnoti}/bin/volnoti -n";
      Restart = "on-failure";
      RestartSec = 1;
    };

    Install = {
      WantedBy = [ "sway-session.target" ];
    };
  };
}
