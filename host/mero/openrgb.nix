{ config, lib, pkgs, ... }:

{
  boot.kernelParams = [ "acpi_enforce_resources=lax" ];
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];
  services.udev.packages = [ pkgs.openrgb ];
  environment.systemPackages = [ pkgs.openrgb ];

  environment.etc."openrgb/default-profile.orp".source = ./Lights-off.orp;

  systemd.services.openrgb = {
    wantedBy = [ "default.target" ];
    script = ''
      ${pkgs.openrgb}/bin/openrgb --noautoconnect --profile /etc/openrgb/default-profile.orp
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    restartTriggers = [ "/etc/openrgb/default-profile.orp" ];
  };
}
