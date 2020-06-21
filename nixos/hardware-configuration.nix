{ config, lib, ... }:

{
  config = lib.mkIf config.boot.loader.grub.enable {
    boot.loader.grub.extraEntries = ''
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
  };
}
