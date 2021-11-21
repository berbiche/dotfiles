{ config, lib, pkgs, rootPath, ... }:

let
  inherit (lib) mkEnableOption types;
  inherit (pkgs.stdenv) isDarwin isLinux;

  cfg = config.profiles.dev.wakatime;
in
{
  options.profiles.dev.wakatime = {
    enable = mkEnableOption "WakaTime component";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.wakatime = lib.mkIf isLinux {
      sopsFile = rootPath + "/secrets/wakatime.cfg";
      mode = "0400";
      format = "binary";
      owner = "${config.my.username}";
      group = "${config.my.username}";
    };

    my.home = { config, osConfig, lib, ... }:
      let wakatimeCfg = "${config.xdg.configHome}/wakatime"; in
      lib.mkMerge [
        (lib.mkIf isLinux {
          systemd.user.sessionVariables.WAKATIME_HOME = wakatimeCfg;
          pam.sessionVariables.WAKATIME_HOME = wakatimeCfg;
          xdg.configFile."wakatime/.wakatime.cfg".source = config.lib.file.mkOutOfStoreSymlink osConfig.sops.secrets.wakatime.path;
        })
        {
          home.sessionVariables.WAKATIME_HOME = wakatimeCfg;
        }
      ];
  };
}
