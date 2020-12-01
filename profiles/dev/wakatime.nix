{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption types;
  cfg = config.profiles.dev.wakatime;
in
{
  options.profiles.dev.wakatime = {
    enable = mkEnableOption "WakaTime component";
  };

  config = lib.mkIf cfg.enable {
    my.home = { config, lib, ... }: {
      home.sessionVariables = {
        WAKATIME_HOME = "${config.xdg.configHome}/wakatime";
      };
      home.activation.wakatime = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
        WAKATIME_HOME="${config.home.sessionVariables.WAKATIME_HOME}"
        mkdir -p $WAKATIME_HOME
        if [ ! -f "$WAKATIME_HOME/.wakatime.cfg" ]; then
          cat "$WAKATIME_HOME/.wakatime.cfg" <<<'${''
            [settings]
            hide_file_names = true
            api_url = https://wakatime.notarock.xyz/api/heartbeat
            api_key = secret
            [git]
            disable_submodules = true
          ''}'
        fi
      '';
    };
  };
}
