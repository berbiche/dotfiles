{ config, lib, pkgs, ... }:

let
  theme = config.my.colors;
  transparency = lvl: color:
    assert lvl <= 100 && lvl >= 0;
    color + lib.toHexString (lvl * 256 / 100);

  partial-transparency = transparency 90;
in
{
  services.dunst.iconTheme = {
    name = config.my.theme.icon.name;
    package = config.my.theme.icon.package;
    size = "64x64";
  };
  services.dunst.settings = {
    global = {
      font = "Sans 10";
      markup = "full";
      format = "<b>%s</b>\\n%b";
      follow = "keyboard";

      # Wayland option
      layer = "top";

      alignment = "top";
      icon_position = "left";
      vertical_alignment = "top";
      origin = "top-center";
      height = "(70, 250)";
      width = "350";
      offset = "0x10";
      min_icon_size = 64/*px*/;
      max_icon_size = 64/*px*/;
      notification_limit = 4;

      line_height = 3;
      separator_height = 10/*px*/;
      padding = 6/*px*/;
      horizontal_padding = 6/*px*/;

      ellipsize = "end";
      hide_duplicate_count = true;
      history_length = 15;
      idle_threshold = 0;
      ignore_newline = false;
      indicate_hidden = false;
      show_age_threshold = -1;
      show_indicators = false;
      shrink = false;
      sort = false;
      stack_duplicates = true;
      sticky_history = false;
      word_wrap = true;

      dmenu = "${pkgs.wofi}/bin/wofi -p dunst -dmenu";
      browser = "${config.programs.firefox.package}/bin/firefox --new-tab";

      corner_radius = 4;
      frame_color = theme.color8;
      frame_width = 2;
      separator_color = "frame";
    };
    urgency_low = {
      background = partial-transparency theme.color1;
      foreground = theme.color4;
      frame_color = theme.color8;
      timeout = 10;
    };
    urgency_normal = {
      background = partial-transparency theme.color1;
      foreground = theme.color4;
      frame_color = theme.color8;
      timeout = 10;
    };
    urgency_critical = {
      background = partial-transparency theme.color1;
      foreground = theme.color4;
      frame_color = theme.color8;
      timeout = 10;
    };
  };
}
