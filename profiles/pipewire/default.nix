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
  imports = [
    ./loopback.nix
    ./lowlatency.nix
  ];

  options.profiles.pipewire.enable = mkEnableOption "pipewire replacement of Pulseaudio";

  config = mkMerge [
    (mkIf cfg.enable {
      my.home.imports = [ ./home-manager.nix ];

      sound.enable = false;
      hardware.pulseaudio.enable = false;

      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };

      # Fix a bug with Discord
      # See https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/2197
      # and https://www.reddit.com/r/archlinux/comments/t45chj/discord_pipewire_no_notification_sounds/
      services.pipewire.config.pipewire-pulse = {
        "pulse.rules" = defaultPipewirePulseJson."pulse.rules" or [ ] ++ [
          # {
          #   matches = [
          #     { "application.process.binary" = "~.+Discord.+"; }
          #     # { "application.process.binary" = ".Discord-wrapped"; }
          #   ];
          #   actions.update-props = {
          #     "pulse.min.quantum" = "1024/48000";
          #   };
          # }
        ];
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
