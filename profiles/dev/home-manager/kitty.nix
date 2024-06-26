{ config, pkgs, lib, ... }:

let
  kitty-kitten-search = pkgs.fetchFromGitHub {
    owner = "trygveaa";
    repo = "kitty-kitten-search";
    rev = "0760138fad617c5e4159403cbfce8421ccdfe571";
    hash = "sha256-egisza7V5dWplRYHIYt4bEQdqXa4E7UhibyWJAup8as=";
  };
in
{
  programs.kitty.enable = true;

  programs.kitty.font = {
    size = builtins.floor config.my.terminal.fontSize;
    name = config.my.terminal.fontName;
  };

  programs.kitty.settings = {
    # Disable auto-update checking
    update_check_interval = 0;

    cursor_shape = "block";

    scrollback_lines = 10000;

    enable_audio_bell = false;
    # 200 milliseconds
    visual_bell_duration = "0.2";

    remember_window_size = false;

    tab_bar_edge = "top";
    tab_bar_style = "powerline";

    sync_to_monitor = true;

    background_opacity = "0.8";
    dynamic_background_opacity = true;
    window_padding_width = "2";
    # window_padding_height = "2";

    macos_option_as_alt = "left";
  };

  programs.kitty.keybindings = {
    # Font size stuff
    "ctrl+shift+equal" = "change_font_size current +2.0";
    "ctrl+shift+plus" = "change_font_size current +2.0";
    "cmd+plus" = "change_font_size current +2.0";
    "cmd+equal" = "change_font_size current +2.0";
    # Decrease font size
    "ctrl+shift+minus" = "change_font_size current -2.0";
    "cmd+minus" = "change_font_size current -2.0";
    # Reset font size
    "ctrl+shift+backspace" = "change_font_size current 0";
    "cmd+backspace" = "change_font_size current 0";

    "opt+cmd+r" = "clear_terminal reset all";

    # Searching
    "ctrl+shift+f" = "launch --location=hsplit --allow-remote-control kitty +kitten kitten_search/search.py @active-kitty-window-id";
  };

  xdg.configFile."kitty/kitten_search".source = kitty-kitten-search;
}
