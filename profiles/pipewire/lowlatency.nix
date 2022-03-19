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
  options.profiles.pipewire.enableLowLatency = mkEnableOption "low latency configuration for Pipewire";

  config = mkIf (cfg.enable && cfg.enableLowLatency) {
    services.pipewire.config.pipewire = {
      "properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 1024;
        "default.clock.min-quantum" = 32;
        # Can't be set too low with my devices unfortunately
        "default.clock.max-quantum" = 8192;
      };
      "context.modules" = [
        {
          name = "libpipewire-module-rtkit";
          args = {
            "nice.level" = -15;
            "rt.prio" = 88;
            "rt.time.soft" = 200000;
            "rt.time.hard" = 200000;
          };
          flags = [ "ifexists" "nofail" ];
        }
      ]
      # Skip the rtkit module since I replace its configuration
      ++ builtins.filter (x: x.name != "libpipewire-module-rtkit") (defaultPipewireJson."context.modules" or []);
    };
    services.pipewire.config.pipewire-pulse = {
      "context.properites"."log.level" = logLevel.DEBUG;
      "stream.properties" = {
        # "node.latency" = "32/48000";
        "resample.quality" = 10;
      };
      "context.modules" = [
        {
          name = "libpipewire-module-rtkit";
          args = {
            "nice.level" = -15;
            "rt.prio" = 88;
            "rt.time.soft" = 200000;
            "rt.time.hard" = 200000;
          };
          flags = [ "ifexists" "nofail" ];
        }
      ]
      # Skip the rtkit module and the protocol-pulse module since I replace their configuration
      ++ builtins.filter
        (x: x.name != "libpipewire-module-rtkit" && x.name != "libpipewire-module-protocol-pulse")
        (defaultPipewirePulseJson."context.modules" or [])
      ++ [
        {
          name = "libpipewire-module-protocol-pulse";
          args = {
            "pulse.min.req" = "32/48000";
            "pulse.default.req" = "32/48000";
            "pulse.max.req" = "4096/48000";
            "pulse.default.frag" = "96000/48000";
            "pulse.max.frag" = "96000/48000";
            "pulse.min.quantum" = "32/48000";
            "pulse.max.quantum" = "8192/48000";
            "server.address" = [ "unix:native" ];
            "vm.overrides" = {
              "pulse.max.quantum" = "8192/48000";
            };
          };
        }
      ];
    };
  };
}
