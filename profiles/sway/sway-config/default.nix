{ ... }:

{
  my.home = { config, options, lib, pkgs, ... }: let
    swayConfig = config.lib.my.callWithDefaults ./config.nix { inherit config options; };
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
      # I don't need Home Manager's Sway, only the configuration
      package = null;

      # We handle the on-startup ourselves now
      systemdIntegration = false;
      xwayland = true;

      inherit (swayConfig) config extraConfig;
    };

    systemd.user.services.waybar = {
      Install.WantedBy = lib.mkForce [ "sway-session.target" ];
    };
  };
}
