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
  options.profiles.pipewire.enable = mkEnableOption "pipewire replacement of Pulseaudio";
  options.profiles.pipewire.enableLowLatency = mkEnableOption "low latency configuration for Pipewire";
  options.profiles.pipewire.loopbackTargets = mkOption {
    type = types.listOf types.str;
    default = [ ];
    description = "Loopback targets for the main primary output";
  };

  config = mkMerge [
    (mkIf (cfg.enable && cfg.loopbackTargets != []) {
      # Pipewire 0.3.44 has a bug where muting a loopback device
      # does not mute the audio going to the sub-devices ("slaves").
      # I am forced to use the module-combine-sink because it DOES NOT have this bug.
      # `pw-loopback` does not have this bug either...
      services.pipewire.config.pipewire-pulse."context.exec" =
        (defaultPipewireJson."context.exec" or [ ])
        ++ [
          {
            path = "/bin/sh";
            args = pkgs.writeShellScript "combine-sink" ''
              ${pkgs.pulseaudio}/bin/pactl load-module module-combine-sink sink_name=combine sink_properties=device.description='Combined Output' format=s16le rate=48000 channels=2 channel_map=front-left,front-right slaves=${escapeShellArg (concatStringsSep "," cfg.loopbackTargets)}
            '';
          }
        ];
    })
    (mkIf (cfg.enable && cfg.enableLowLatency) {
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
    })
    (mkIf cfg.enable {
      sound.enable = false;
      hardware.pulseaudio.enable = false;

      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;

        media-session.enable = true;
      };

      services.pipewire.config.pipewire = {
        "properties" = {
          "link.max.buffers" = 16;
          "log.level" = logLevel.DEBUG;
          # "core.daemon" = true;
          # "core.name" = "pipewire-0";
        };
        # "context.modules" =
        #   # Reuse the default configuration, I don't use the `attribute.something or` syntax
        #   # because I want a build-time failure
        #   defaultPipewireJson."context.modules"
        #   ++ (lib.flip imap0 (cfg.loopbackTargets) (i: target: {
        #     name = "libpipewire-module-loopback";
        #     args = {
        #       "audio.position" = [ "FL" "FR" ];
        #       "capture.props" =
        #         # Only create the virtual sink for the first element
        #         if i == 0 then
        #           {
        #             "media.class" = "Audio/Sink";
        #             "node.name" = "Combined-Output";
        #             "node.description" = "Main Output";
        #           }
        #         # The other elements will target the previously created virtual sink
        #         else
        #           {
        #             "node.target" = "Combined-Output";
        #           }
        #       ;
        #       "playback.props" = {
        #         "node.target" = target;
        #       };
        #     };
        #   }));
        "context.objects" = [
          # {
          #   factory = "spa-node-factory";
          #   args = {
          #     "factory.name"    = "support.node.driver";
          #     "node.name"       = "dummy-driver";
          #     "priority.driver" = 8000;
          #   };
          # }
          # {
          #   factory = "adapter";
          #   args = {
          #     "factory.name"     = "support.null-audio-sink";
          #     "node.name"        = "Microphone-Proxy";
          #     "node.description" = "Microphone";
          #     "media.class"      = "Audio/Source/Virtual";
          #     "audio.position"   = "MONO";
          #     "object.linger"    = true;
          #   };
          # }
          # {
          #   factory = "adapter";
          #   args = {
          #     "factory.name"     = "support.null-audio-sink";
          #     "node.name"        = "Main-Output-Proxy";
          #     "node.description" = "Main Output";
          #     "media.class"      = "Audio/Sink";
          #     "audio.position"   = "FL,FR";
          #     "object.linger"    = true;
          #   };
          # }

          #### Segfaults but a fix is available in 0.3.45
          # {
          #   factory = "link-factory";
          #   args = {
          #     "factory.name"     = "link-factory";
          #     "link.input.node"  = "Main-Output-Proxy";
          #     "link.input.port"  = "monitor_FL";
          #     "link.output.node" = "alsa_output.usb-SteelSeries_SteelSeries_Arctis_7-00.stereo-game";
          #     "link.output.port" = "playback_FL";
          #     "object.linger"    = true;
          #   };
          #   flags = [ "nofail" ];
          # }
          # {
          #   factory = "link-factory";
          #   args = {
          #     "factory.name"     = "link-factory";
          #     "link.input.node"  = "Main-Output-Proxy";
          #     "link.input.port"  = "monitor_FR";
          #     "link.output.node" = "alsa_output.usb-SteelSeries_SteelSeries_Arctis_7-00.stereo-game";
          #     "link.output.port" = "playback_FR";
          #     "object.linger"    = true;
          #   };
          #   flags = [ "nofail" ];
          # }
          # {
          #   factory = "link-factory";
          #   args = {
          #     "factory.name"     = "link-factory";
          #     "link.input.node"  = "Main-Output-Proxy";
          #     "link.input.port"  = "monitor_FR";
          #     "link.output.node" = "alsa_output.pci-0000_0e_00.4.analog-stereo";
          #     "link.output.port" = "playback_FR";
          #     "object.linger"    = true;
          #   };
          #   flags = [ "nofail" ];
          # }
          # {
          #   factory = "link-factory";
          #   args = {
          #     "factory.name"     = "link-factory";
          #     "link.input.node"  = "Main-Output-Proxy";
          #     "link.input.port"  = "monitor_FL";
          #     "link.output.node" = "alsa_output.pci-0000_0e_00.4.analog-stereo";
          #     "link.output.port" = "playback_FL";
          #     "object.linger"    = true;
          #   };
          #   flags = [ "nofail" ];
          # }
        ];
      };
    })
    (mkIf (!cfg.enable) {
      # Enable sound. Required for pulseaudio support
      sound.enable = true;
      hardware.pulseaudio = {
        enable = true;
        extraModules = [ pkgs.pulseaudio-modules-bt ];
        package = pkgs.pulseaudioFull;
        support32Bit = true;
      };
    })
  ];
}
