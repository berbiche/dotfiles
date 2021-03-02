{ config, lib, pkgs, ... }:

let
  swaymsg = "${pkgs.sway}/bin/swaymsg";

  displays = lib.mapAttrs (_: v: v // { position = "0,0"; status = "enable"; }) rec {
    benq = {
      criteria = "BenQ Corporation BenQ EW3270U 74J08749019";
      mode = "3840x2160@60Hz";
    };
    dell-1 = {
      criteria = "Dell Inc. DELL U2414H R9F1P55S45FL";
      mode = "1920x1080@60Hz";
    };
    dell-2 = {
      criteria = "Dell Inc. DELL U2414H R9F1P56N68VL";
      mode = "1920x1080@60Hz";
    };
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
      # mode = "5120x1440@119.99Hz";
    };
  };

  benq-dell = displays.benq // { position = "1080,0"; };
  benq-dell-1 = displays.dell-1 // { position = "0,0"; transform = "270"; };
  benq-dell-2 = displays.dell-2 // { position = "4920,0"; transform = "90"; };
  disable-laptop = displays.laptop // { status = "disable"; };
  enable-benq-adaptive-sync = ''${swaymsg} output '"${displays.benq.criteria}"' adaptive_sync on'';

  genDisableLaptop = lib.flip lib.mergeAttrsConcatenateValues { outputs = [ disable-laptop ]; };

  configs = {
    g9-with-two-cables.outputs = [
      (displays.g9 // { criteria = "DP-1"; status = "disable"; } )
      (displays.g9 // { criteria = "HDMI-A-1"; status = "enable"; })
    ];

    g9-dsc.outputs = [ displays.g9-dsc ];

    lone-benq = {
      outputs = [ displays.benq ];
      # exec = enable-benq-adaptive-sync;
    };

    old-triple-dell = {
      outputs = [ benq-dell-1 benq-dell benq-dell-2 ];
      # exec = enable-benq-adaptive-sync;
    };

    benq-dell-left = {
      outputs = [ benq-dell-1 benq-dell ];
      # exec = enable-benq-adaptive-sync;
    };

    benq-dell-right = {
      outputs = [ benq-dell benq-dell-2 ];
      # exec = enable-benq-adaptive-sync;
    };

    home-dell-lone.outputs = [ displays.dell-3 ];

    home-dell.outputs = [
      (displays.dell-3 // { position = "1080,0"; })
      (displays.dell-2 // { transform = "90"; })
    ];

    lenovo-benq = {
      outputs = [
        (displays.lenovo // { position = "0,800"; })
        (displays.benq // { position = "3840,0"; scale = 1.5; transform = "270"; })
      ];
      # exec = ''${pkgs.sway}/bin/swaymsg output '"${displays.lenovo.criteria}"' adaptive_sync on,''
      #        + ''output '"${displays.benq.criteria}"' adaptive_sync on'';
    };
  };
in
{
  services.kanshi = {
    enable = true;

    profiles = lib.foldl' lib.mergeAttrs { } [
      configs
      # All the same configurations with the laptop screen disabled when using the docking station
      (lib.mapAttrs' (n: v: lib.nameValuePair "${n}-disable-laptop" (genDisableLaptop v)) configs)
      # Extra configurations
      {
        lenovo-thinkpad.outputs = [
          (displays.laptop // { position = "0,0"; })
          (displays.lenovo // { position = "3840,800"; })
        ];
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
    Install.WantedBy = lib.mkForce [ "sway-session.target" ];
  };
}
