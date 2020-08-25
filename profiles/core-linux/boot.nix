{ config, lib, ... }:

{
  boot.cleanTmpDir = true;
  boot.loader.grub.extraEntries = lib.mkIf config.boot.loader.grub.enable ''
    menuentry "Shutdown" {
      halt
    }
    menuentry "Reboot" {
      reboot
    }
    menuentry "Bios" {
      fwsetup
    }
  '';
}
