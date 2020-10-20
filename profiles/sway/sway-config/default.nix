{ config, rootPath, ... }:

{
  home-manager.users.${config.my.username} = { config, lib, pkgs, ... }: let
    swayConfig = pkgs.callWithDefaults ./config.nix { inherit config rootPath; };
  in {
    home.packages = with pkgs; [
      xdg-desktop-portal-wlr

      # oblogout alternative
      wlogout
      wl-clipboard
      wdisplays
      # libinput gestures utility
      gebaar-libinput
      # Used in scripts
      brightnessctl
      grim
      slurp
      wofi
      swaylock
    ];

    wayland.windowManager.sway = {
      enable = true;
      package = null;
      # For the sway-session.target
      systemdIntegration = true;
      xwayland = true;

      inherit (swayConfig) config extraConfig;
    };

    systemd.user.targets.sway-session.Unit = {
      Description = "sway compositor session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = lib.mkForce [ "wayland-session.target" ];
      Wants = lib.mkForce [ "wayland-session.target" ];
      After = lib.mkForce [ "wayland-session.target" ];
    };

    # Idle service
    systemd.user.services.sway-idle =
      let
        swaylock = "${pkgs.swaylock}/bin/swaylock";
        swayidle = "${pkgs.swayidle}/bin/swayidle";
        swaymsg  = "${pkgs.sway}/bin/swaymsg";
      in {
        Unit = {
          Description = "Idle manager for Wayland";
          Documentation = "man:swayidle(1)";
          PartOf = [ "wayland-session.target" ];
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
        Install.WantedBy = [ "sway-session.target" ];
      };

    systemd.user.services.waybar.Install.WantedBy = [ "sway-session.target" ];

    systemd.user.services.volnoti = {
      Unit = {
        Description = "Lightweight volume notification daemon";
        Requisite = [ "dbus.service" ];
        After = [ "dbus.service" ];
        PartOf = [ "wayland-session.target" ];
      };

      Service = {
        Type = "dbus";
        BusName = "uk.ac.cam.db538.volume-notification";
        ExecStart = "${pkgs.volnoti}/bin/volnoti -n";
        Restart = "on-failure";
        RestartSec = 1;
      };

      Install.WantedBy = [ "sway-session.target" ];
    };
  };
}
