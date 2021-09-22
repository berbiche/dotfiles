{
  my.home = {
    programs.gh = {
      enable = true;
      gitProtocol = "ssh";
      # prompt = "enabled";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
        rc = ''!gh repo create "$(basename "$(pwd)")" "$@"'';
      };
    };
  };
}
