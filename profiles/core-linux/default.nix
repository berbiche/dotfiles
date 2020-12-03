{ config, pkgs, lib, ... }:

{
  imports = [
    ./boot.nix
    ./services.nix
  ];

  networking.networkmanager.enable = true;

  # Virtualization
  virtualisation.docker.enable = true;

  time.timeZone = "America/Montreal";
  location.provider = "geoclue2";

  networking.firewall.enable = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" "9.9.9.9" ];

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
    support32Bit = true;
  };

  # Add a folder in $XDG_RUNTIME_DIR to be used as my own temporary directory
  my.home = {
    systemd.user.tmpfiles.rules = [
      #Type Path   Mode User Group Age Argument
      "D    %t/tmp 0550 -    -     -   -"
    ];
  };
}
