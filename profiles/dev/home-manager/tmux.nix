{ config, lib, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    # Use C-a
    shortcut = "a";
    baseIndex = 1;
    escapeTime = 0;

    historyLimit = 10000;

    clock24 = true;
    # customPaneNavigationAndResize = true;

    plugins = with pkgs.tmuxPlugins; [
      {
        # Show when the prefix is used in the status bar
        plugin = prefix-highlight;
      }
      {
        # Easymotion/Acejump: type 1 char to jump to a word
        plugin = jump;
      }
      {
        plugin = power-theme;
        extraConfig = ''
          set -g @tmux_power_theme 'redwine'
          set -g @tmux_power_prefix_highlight_pos 'L'
        '';
      }
    ];

    extraConfig = ''
      set -g mouse on
    '';
  };
}
