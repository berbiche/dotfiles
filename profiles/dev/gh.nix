{
  my.home = {
    programs.gh = {
      enable = true;
      settings.gitProtocol = "ssh";
      # prompt = "enabled";
      settings.aliases = {
        aliases = "alias list";
        co = "pr checkout";
        pv = "pr view";
        rc = ''!gh repo create "$(basename "$(pwd)")" "$@"'';
        rcl = "repo clone";
      };
    };
  };
}
