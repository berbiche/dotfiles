{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.sway;
in
{
  options.profiles.sway.nvidia.enable = mkEnableOption "Nvidia specific settings for Sway and Wlroots compatiblity";
  options.profiles.sway.enableGtklock = mkEnableOption "gtklock swaylock replacement";

  config = mkMerge [
    (mkIf cfg.nvidia.enable {
      programs.sway.extraOptions = [ " --unsupported-gpu " " -D noscanout " ];

      programs.sway.extraSessionCommands = mkBefore ''
        export WLR_NO_HARDWARE_CURSORS=1
        export WLR_DRM_NO_ATOMIC=1
        # export WLR_DRM_NO_MODIFIERS=1
      '';
    })
    (mkIf cfg.enableGtklock {
      environment.systemPackages = [ pkgs.gtklock ];
      security.pam.services.gtklock = {};
    })
  ];
}
