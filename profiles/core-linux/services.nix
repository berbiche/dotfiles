{ config, pkgs, lib, ... }:

{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluez5;
  #hardware.bluetooth.package = pkgs.bluezFull;

  # Allow updating the firmware of various components
  services.fwupd.enable = true;

  #
  services.acpid.enable = true;

  # Forward journald logs to VTT 1
  # Doesn't work
  #services.journald.extraConfig = ''
  #  FordwardToConsole=yes
  #  TTYPath=/dev/tty1
  #'';

  # Yubikey
  services.udev.packages = with pkgs; [ yubikey-personalization libu2f-host ];
  services.pcscd.enable = true;

  # Enable insults on wrong `sudo` password input
  security.sudo.extraConfig = lib.mkAfter ''
    Defaults !insults
    Defaults:%wheel insults
  '';
}
