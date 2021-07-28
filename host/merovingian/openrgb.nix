{ config, lib, pkgs, ... }:

{
  boot.kernelParams = [ "acpi_enforce_resources=lax" ];
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];
  services.udev.packages = [ pkgs.openrgb ];
  environment.systemPackages = [ pkgs.openrgb ];

  systemd.services.openrgb = let
    configFile = ./Lights-off.orp;
  in {
    wantedBy = [ "default.target" ];
    script = ''
    ${pkgs.openrgb}/bin/openrgb --noautoconnect --server --server-port 43321 --profile ${configFile}
    '';
    serviceConfig = {
      User = "nobody";
      RemainAfterExit = true;
    };
    restartTriggers = [ configFile ];
  };
}
