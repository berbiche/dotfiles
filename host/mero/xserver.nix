{ config, ... }:

{
  # Make the configuration available at `/etc/X11/xorg.conf`
  services.xserver.exportConfiguration = true;

  services.xserver.extraConfig = ''
    Section "Device"
      Identifier "Device0"
      Driver     "nvidia"
      VendorName "NVIDIA Corporation"
      BoardName  "NVIDIA GeForce RTX 3080 Ti"
    EndSection

    Section "Monitor"
      Identifier  "Monitor-Philips"
      VendorName  "Unknown"
      ModelName   "Philips PHL346B1C"
      HorizSync   160.0 - 160.0
      VertRefresh 48.0 - 100.0
    EndSection

    Section "Monitor"
      Identifier  "Monitor-Samsung"
      # ModelName   ""
    EndSection

    Section "Screen"
      Identifier     "Screen-Samsung"
      Device         "Device0"
      Monitor        "Monitor-Samsung"
      DefaultDepth   24
      Option         "Stereo" "0"
      Option         "metamodes" "5120x1440_120 +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"
      Option         "AllowIndirectGLXProtocol" "off"
      Option         "TripleBuffer" "on"
      Option         "SLI" "Off"
      Option         "MultiGPU" "Off"
      Option         "BaseMosaic" "off"
      SubSection "Display"
        Depth  24
        Modes  "5120x1440"
      EndSubSection
    EndSection

    Section "Screen"
      Identifier     "Screen-Philips"
      Device         "Device0"
      Monitor        "Monitor-Philips"
      DefaultDepth    24
      Option         "Stereo" "0"
      Option         "metamodes" "3440x1440_100 +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On}"
      Option         "AllowIndirectGLXProtocol" "off"
      Option         "TripleBuffer" "on"
      Option         "SLI" "Off"
      Option         "MultiGPU" "Off"
      Option         "BaseMosaic" "off"
      SubSection     "Display"
        Depth       24
      EndSubSection
    EndSection
  '';
}
