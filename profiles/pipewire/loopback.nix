{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.pipewire;

  defaultPipewireJson = importJSON "${pkgs.path}/nixos/modules/services/desktops/pipewire/daemon/pipewire.conf.json";
  defaultPipewirePulseJson = importJSON "${pkgs.path}/nixos/modules/services/desktops/pipewire/daemon/pipewire-pulse.conf.json";

  logLevel = {
    WARNING = 2;
    DEBUG = 4;
  };
in
{
  options.profiles.pipewire.loopbackTargets = mkOption {
    type = types.attrsOf (types.listOf types.str);
    default = { };
    description = "Loopback targets for the main primary output";
  };

  config = mkIf (cfg.enable && cfg.loopbackTargets != { }) {
    # Pipewire 0.3.44 has a bug where muting a loopback device
    # does not mute the audio going to the sub-devices ("slaves").
    # I am forced to use the module-combine-sink because it DOES NOT have this bug.
    # `pw-loopback` does not have this bug either...
    services.pipewire.config.pipewire-pulse = {
      "context.exec" =
        (defaultPipewireJson."context.exec" or [ ])
        ++ mapAttrsToList (name: value:
          {
            path = "/bin/sh";
            args = pkgs.writeShellScript "combine-sink" ''
              ${pkgs.pulseaudio}/bin/pactl load-module module-combine-sink \
                 sink_name=${escapeShellArg name} sink_properties=device.description='Combined Output '${escapeShellArg name} \
                 format=s16le rate=48000 channels=2 channel_map=front-left,front-right \
                 slaves=${escapeShellArg (concatStringsSep "," value)}
            '';
          }
        ) cfg.loopbackTargets;
    };
  };
}
