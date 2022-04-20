{ config, lib, pkgs, ... }:

{
  imports = [
    ./i3-config.nix
    ./keybindings.nix
    ./modes.nix
    ./binaries.nix
    ./services.nix
    ./picom.nix
    ./polybar.nix
  ];

  options.profiles.i3.binaries = lib.mkOption {
    type = lib.types.attrsOf (lib.types.oneOf [ lib.types.str lib.types.package ]);
  };

  config = {
    home.packages = [
      pkgs.xclip         # copy/paste
      pkgs.lightlocker   # lockscreen that integrates with lightdm
      pkgs.nitrogen      # wallpaper
    ];

    xsession.enable = true;

    systemd.user.targets.x11-session = {
      Unit = {
        Description = "X11 compositor session";
        Documentation = [ "man:systemd.special(7)" ];
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
    };

    xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
    };
  };
}
