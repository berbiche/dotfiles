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
        # Mnemonic: pr mine
        prm = "pr list --author=berbiche";
        # Create a repo for my user
        rc = ''!gh repo create "''${PWD##*/}" "$@"'';
        rcl = "repo clone";
      };
    };
  };
}
