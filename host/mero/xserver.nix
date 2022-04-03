{ config, ... }:

{
  services.xserver.deviceSection =''
  '';

  services.xserver.screenSection = ''
    Option "Stereo" "0"
    Option "metamodes" "nvidia-auto-select +0+0; 5120x1440 +0+0 {ForceCompositionPipeline=On}"
  '';
}
