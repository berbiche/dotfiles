{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

  defaultFontSize = config.my.terminal.fontSize;
  defaultFont = config.my.terminal.fontName;
in
{
  programs.alacritty.enable = true;
  programs.alacritty.settings = {
    env = { };

    # TERM = "alacritty";

    window = {
      dynamic_title = true;
      dimensions = {
        columns = 0;
        lines = 0;
      };

      opacity = 0.8;

      padding = {
        x = 5;
        y = 5;
      };

      decorations = "full";
    };

    scrolling = {
      # Specifying '0' will disable scrolling.
      history = 10000;

      # Number of lines the viewport will move for every line scrolled when
      # scrollback is enabled (history > 0).
      multiplier = 3;
    };

    font = {
      size = defaultFontSize;
      normal.family = defaultFont;
      normal.style = "Regular";
      bold.family = defaultFont;
      bold.style = "Bold";
      italic.family = defaultFont;
      italic.style = "Italic";
      bold_italic.family = defaultFont;
      bold_italic.style = "Bold Italic";
    };

    # Colors (Tomorrow Night Bright)
    colors = {
      # Default colors
      primary = {
        background = "0x000000";
        foreground = "0xeaeaea";
      };

      # Normal colors
      normal = {
        black =   "0x000000";
        red =     "0xd54e53";
        green =   "0xb9ca4a";
        yellow =  "0xe6c547";
        blue =    "0x7aa6da";
        magenta = "0xc397d8";
        cyan =    "0x70c0ba";
        white =   "0xeaeaea";
      };
      # Bright colors
      bright = {
        black =   "0x666666";
        red =     "0xff3334";
        green =   "0x9ec400";
        yellow =  "0xe7c547";
        blue =    "0x7aa6da";
        magenta = "0xb77ee0";
        cyan =    "0x54ced6";
        white =   "0xffffff";
      };
    };

    bell = {
      animation = "EaseOutExpo";
      duration = 200;
      color = "0xffffff";
    };

    mouse_bindings = [
      { mouse = "Middle"; action = "PasteSelection"; }
      { mouse = 4; action = "PasteSelection"; }
      { mouse = 5; action = "Paste"; }
    ];

    mouse = {
      hide_when_typing = false;
    };

    hints = {
      enabled = [
        {
          regex = "(ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:|git\\\\+ssh:)[^\\u0000-\\u001F\\u007F-\\u009F<>\"\\\\s{-}\\\\^⟨⟩`]+";
          command = if isDarwin then "open" else "xdg-open";
          post_processing = true;
          mouse = {
            enabled = true;
            mods = "Control";
          };
        }
      ];
    };

    line_indicator.foreground = "#c5c8c6";

    selection = {
      save_to_clipboard = false;
    };

    cursor = {
      style = "Block";
      vi_mode_style = "Block";
      unfocused_hollow = true;
    };

    # Send ESC (\x1b) before characters when alt is pressed.
    alt_send_esc = true;
  };
}
