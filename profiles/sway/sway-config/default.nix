{ rootPath, ... }:

{
  my.home = { config, options, lib, pkgs, ... }: let
    swayConfig = config.lib.my.callWithDefaults ./config.nix { inherit config options rootPath; };
  in {
    home.packages = with pkgs; [
      # oblogout alternative
      wlogout
      wl-clipboard
      wdisplays
      brightnessctl
      grim
      slurp
      wofi
      swaylock
    ];

    wayland.windowManager.sway = {
      enable = true;
      # I don't need Home Manager's Sway, only the wrapped one provided by
      # my NixOS options
      package = null;
      # For the sway-session.target
      systemdIntegration = true;
      xwayland = true;

      inherit (swayConfig) config extraConfig;
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
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
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

    systemd.user.services.waybar = {
      Install.WantedBy = lib.mkForce [ "sway-session.target" ];
    };

    # To use with `volnoti-show` to display a transparent window with the volume level
    systemd.user.services.volnoti = {
      Unit = {
        Description = "Lightweight volume notification daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
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
