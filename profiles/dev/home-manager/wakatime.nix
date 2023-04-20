{ config, lib, pkgs, rootPath, ... }:

let
  inherit (lib) mkEnableOption types;
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

  cfg = config.profiles.dev.wakatime;

  wakatimeCfg = "${config.xdg.configHome}/wakatime";
in
{
  options.profiles.dev.wakatime = {
    enable = mkEnableOption "WakaTime component";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.wakatime = {
      sopsFile = rootPath + "/secrets/wakatime.cfg";
      mode = "0400";
      format = "binary";
      path = "${wakatimeCfg}/.wakatime.cfg";
    };

    systemd.user.sessionVariables.WAKATIME_HOME = wakatimeCfg;

    home.sessionVariables.WAKATIME_HOME = wakatimeCfg;
    
    xdg.configFile."wakatime/.keep".text = "Managed by Home Manager.";
  };
}
