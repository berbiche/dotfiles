{ config, pkgs, ... }:

{
  home.sessionVariables = {
    NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/config";
    NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
    NPM_CONFIG_TMP = "\${TMP:-$XDG_RUNTIME_DIR}/npm";
    NPM_CONFIG_PREFIX = "${config.xdg.cacheHome}/npm";
    NODE_REPL_HISTORY = "${config.xdg.cacheHome}/node/repl_history";
  };

  xdg.configFile."npm/config".text = ''
    cache=${config.xdg.cacheHome}/npm
    prefix=${config.xdg.dataHome}/npm
  '';
}
