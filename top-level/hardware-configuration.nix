{ lib, ... }:

{
  boot.loader.grub.extraEntries = lib.mkAfter ''
    menuentry "Shutdown" {
      halt
    }
    menuentry "Reboot" {
      reboot
    }
  '';
}
