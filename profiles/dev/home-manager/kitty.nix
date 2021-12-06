{ config, pkgs, lib, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

  # This ought to be made into a user-configurated variable
  defaultFontSize = 13;
  defaultFont = lib.mkMerge [
    (lib.mkIf isDarwin "Menlo")
    (lib.mkIf (!isDarwin) "Iosevka")
  ];
in
{
  programs.kitty.enable = true;

  programs.kitty.font = {
    size = defaultFontSize;
    name = defaultFont;
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

    background_opacity = "0.8";
    dynamic_background_opacity = true;

    macos_option_as_alt = true;
  };
}
