{ config, ... }:

{
  services.xserver.resolutions = [ { x = "5120"; y = "1440"; } ];

  services.xserver.exportConfiguration = true;

  services.xserver.screenSection = ''
    DefaultDepth    24
    Option         "Stereo" "0"
    Option         "metamodes" "DP-4: 5120x1440_120 +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}; nvidia-auto-select +0+0"
  '';
}
