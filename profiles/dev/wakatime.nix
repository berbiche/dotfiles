{ config, lib, pkgs, ... }:

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
    my.home = { config, lib, ... }: 
      let wakatimeCfg = "${config.xdg.configHome}/wakatime"; in
    lib.mkMerge [
      (lib.mkIf pkgs.stdenv.isLinux {
        # Use PAM to have it inside Emacs systemd service (not sure it works)?
        pam.sessionVariables.WAKATIME_HOME = wakatimeCfg;
      })
      {
        home.sessionVariables.WAKATIME_HOME = wakatimeCfg;
        home.activation.wakatime = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
          WAKATIME_HOME="wakatimeCfg"
          mkdir -p $WAKATIME_HOME
          if [ ! -f "$WAKATIME_HOME/.wakatime.cfg" ]; then
            cat >"$WAKATIME_HOME/.wakatime.cfg" <<<'${''
              [settings]
              hide_file_names = true
              api_url = https://wakatime.notarock.xyz/api/heartbeat
              api_key = secret
              [git]
              disable_submodules = true
            ''}'
          fi
        '';
      }
    ];
  };
}
