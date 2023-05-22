{ ... }:

{
  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
    # prompt = "enabled";
    settings.aliases = {
      aliases = "alias list";
      co = "pr checkout";
      pv = "pr view";
      prc = "pr create";
      # Mnemonic: pr mine
      prm = "pr list --author=berbiche";
      # Create a repo for my user
      rc = ''!gh repo create "''${$(pwd)##*/}" "$@"'';
      rcl = "repo clone";
      open = "repo view -w";
    };
  };
}
