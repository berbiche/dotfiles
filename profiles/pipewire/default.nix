{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.pipewire;
in
{
  options.profiles.pipewire.enable = mkEnableOption "pipewire replacement of Pulseaudio";

  config = mkMerge [
    {
    }
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
      };
      services.pipewire.config.pipewire = {
        "properties" = {
          "link.max.buffers" = 16;
          "log.level" = 2;
          # "core.daemon" = true;
          # "core.name" = "pipewire-0";
        };
        # "context.objects" = [
        #   {
        #     factory = "spa-node-factory";
        #     args = {
        #       "factory.name"    = "support.node.driver";
        #       "node.name"       = "dummy-driver";
        #       "priority.driver" = 8000;
        #     };
        #   }
        #   {
        #     factory = "adapter";
        #     args = {
        #       "factory.name"     = "support.null-audio-sink";
        #       "node.name"        = "Microphone-Proxy";
        #       "node.description" = "Microphone";
        #       "media.class"      = "Audio/Source/Virtual";
        #       "audio.position"   = "MONO";
        #     };
        #   }
        #   {
        #     factory = "adapter";
        #     args = {
        #       "factory.name"     = "support.null-audio-sink";
        #       "node.name"        = "Main-Output-Proxy";
        #       "node.description" = "Main Output";
        #       "media.class"      = "Audio/Sink";
        #       "audio.position"   = "FL,FR";
        #     };
        #   }
        # ];
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
