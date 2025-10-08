{ config, pkgs, lib, ... }:

{
  programs.ghostty.enable = !pkgs.stdenv.hostPlatform.isDarwin;

  programs.ghostty.settings = {
    font-size = builtins.floor config.my.terminal.fontSize;
    font-family = config.my.terminal.fontName;
    # Non native-fullscreen with menubar to see tabs
    macos-non-native-fullscreen = "visible-menu";
    macos-titlebar-style = "tabs";
    macos-option-as-alt = "left";
  };
}
