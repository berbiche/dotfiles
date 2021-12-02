{ config, lib, pkgs, ... }:

let
  swaymsg = "${pkgs.sway}/bin/swaymsg";

  displays = lib.mapAttrs (_: v: v // { position = "0,0"; status = "enable"; }) rec {
    dell-3 = {
      criteria = "Dell Inc. DELL U3219Q F9WNWP2";
      mode = "3840x2160@60Hz";
    };
    lenovo = {
      criteria = "Lenovo Group Limited LEN P44w-10 0x00007747";
      mode = "3840x1200@144Hz";
    };
    laptop = { criteria = "eDP-1"; };
    g9 = {
      criteria = "Samsung Electric Company LC49G95T H4ZN801309";
      mode = "5120x1440@60Hz";
    };
    g9-dsc = g9 // {
      mode = "5120x1440@239.761Hz";
    };
  };

  disable-laptop = displays.laptop // { status = "disable"; };

  genDisableLaptop = lib.flip lib.mergeAttrsConcatenateValues { outputs = [ disable-laptop ]; };

  configs = {
    g9-dsc.outputs = [ displays.g9-dsc ];
    home-dell-lone.outputs = [ displays.dell-3 ];
  };
in
{
  services.kanshi = {
    enable = true;

    profiles = lib.mkMerge [
      configs
      # All the same configurations with the laptop screen disabled when using the docking station
      (lib.mapAttrs' (n: v: lib.nameValuePair "${n}-disable-laptop" (genDisableLaptop v)) configs)
      # Extra configurations
      {
        # This profile force enables the laptop screen for unknown configurations
        # This profile is the fallback configuration for the laptop (since attrsets in Nix are ordered)
        zzz-fallback-laptop.outputs = [
          (displays.laptop // { status = "enable"; }) # Force enable laptop screen
          { criteria = "*"; mode = "1920x1080"; }
        ];
      }
    ];
  };

  systemd.user.services.kanshi = {
    Unit.ConditionEnvironment = "WAYLAND_DISPLAY";
  };
}
