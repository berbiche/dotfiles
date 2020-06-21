{ config, pkgs, lib, ... }:

{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluez5;
  #hardware.bluetooth.package = pkgs.bluezFull;

  # Allow updating the firmware of various components
  services.fwupd.enable = true;

  # Enable CUPS to print documents.
  #services.printing.enable = true;

  # Enable locate
  services.locate.enable = true;
  services.acpid.enable = true;

  services.blueman.enable = true;

  # networking.wireguard.enable = true;

  # Logitech
  hardware.logitech.enable = true;
  hardware.logitech.enableGraphical = false;

  # Forward journald logs to VTT 1
  services.journald.extraConfig = ''
    FordwardToConsole=yes
    TTYPath=/dev/tty1
  '';

  # Steelseries headset
  services.udev.extraRules = lib.optionalString config.hardware.pulseaudio.enable ''
    ATTRS{idVendor}=="1038", ATTRS{idProduct}=="12ad", ENV{PULSE_PROFILE_SET}="steelseries-arctis-7-usb-audio.conf"
    ATTRS{idVendor}=="1038", ATTRS{idProduct}=="12AD", ENV{PULSE_PROFILE_SET}="steelseries-arctis-7-usb-audio.conf"
  '';

  security.pam.services.gnome-keyring.enableGnomeKeyring = true;

  # Yubikey
  services.udev.packages = with pkgs; [ yubikey-personalization libu2f-host ];
  services.pcscd.enable = true;

  # Enable insults on wrong `sudo` password input
  security.sudo.extraConfig = lib.mkAfter ''
    Defaults !insults
    Defaults:%wheel insults
  '';
}
