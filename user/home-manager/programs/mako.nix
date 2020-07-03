{ config, lib, pkgs, ... }:

{
  programs.mako = {
    enable = true;
    # Display in center
    anchor = "top-right";
    # Show on my primary output
    output = "DP-1";

    icons = true;
    markup = true;
    actions = true;
    defaultTimeout = 10000;
    ignoreTimeout = true;

    # Color settings
    # backgroundColor = "#f4a742F0";
    # textColor = "#000000";
    # borderColor = "#f4a742";
    borderRadius = 5;

    # Wofi styling
    backgroundColor = "#282C34";
    textColor = "#808080";
  };
}
