{ config, lib, ... }:

with lib;

let
  cfg = config.profiles.sway;
in
{
  options.profiles.sway.nvidia.enable = mkEnableOption "Nvidia specific settings for Sway and Wlroots compatiblity";

  config = mkMerge [
    (mkIf cfg.nvidia.enable {
      programs.sway.extraOptions = [ "--unsupported-gpu" ];

      programs.sway.extraSessionCommands = mkBefore ''
        export WLR_NO_HARDWARE_CURSOR=1
      '';
    })
  ];
}
