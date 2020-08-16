{ config, lib, pkgs, ... }:

{
  home.packages = [ pkgs.kanshi ];
  xdg.configFile."kanshi/config".text = ''
    {
      output "Dell Inc. DELL U2414H R9F1P55S45FL" mode 1920x1080@60Hz position 0,0 transform 270
      output "Benq Corporation BenQ EW3270U 74J08749019" mode 3840x2160@60Hz position 1080,0
      output "Dell Inc. DELL U2414H R9F1P56N68VL" mode 1920x1080@60Hz position 4920,0 transform 90
      output eDP-1 disable
    }

    {

      output "Dell Inc. DELL U2414H R9F1P55S45FL" mode 1920x1080@60Hz position 0,0 transform 270
      output "Benq Corporation BenQ EW3270U 74J08749019" mode 3840x2160@60Hz position 1080,0
      output eDP-1 disable
    }

    {
      output "Benq Corporation BenQ EW3270U 74J08749019" mode 3840x2160@60Hz position 1080,0
      output "Dell Inc. DELL U2414H R9F1P56N68VL" mode 1920x1080@60Hz position 4920,0 transform 90
      output eDP-1 disable
    }

    {
      output "Dell Inc. DELL U3219Q F9WNWP2" mode 3840x2160 position 0,0
      output eDP-1 disable
    }

    {
      output "Dell Inc. DELL U3219Q F9WNWP2" mode 3840x2160 position 0,0
      output "Dell Inc. DELL U2414H R9F1P56N68VL" mode 1920x1080@60Hz position 3840,0 transform 270
    }

    {
      output "BenQ Corporation BenQ EW3270U 74J08749019" mode 3840x2160@60Hz position 0,0
      output eDP-1 disable
    }

    {
      output eDP-1 enable
      output * mode 1920x1080
    }

    {
      output "Lenovo Group Limited LEN P44w-10 0x00007747" mode 3840x1200@144Hz position 0,800
      output "BenQ Corporation BenQ EW3270U 74J08749019" mode 3840x2160@60Hz position 3840,0 scale 1.5 transform 90
      exec swaymsg output '"Lenovo Group Limited LEN P44w-10 0x00007747"' adaptive_sync on, \
                   output '"BenQ Corporation BenQ EW3270U 74J08749019"' adaptive_sync on
    }
  '';
}
