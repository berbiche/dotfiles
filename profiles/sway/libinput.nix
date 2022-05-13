# Libinput is a tool that listens for raw input events from a touchpad and emits
# its own event. It makes it possible to use it in conjection with other tools
# like libinput-gestures or gebaard to run libinput and act on these events.
#
# This libinput{-gestures, gebaard} configuration inject keypresses with ydotool.
#
# Currently, the injected inputs are:
#   - Next workspace
#   - Previous workspace
#   - Next page in web browser history (Alt+Right)
#   - Previous page in web browser history (Alt+Left)
#
{ config, pkgs, lib, ... }:

let
  ydotool = "${pkgs.ydotool}/bin/ydotool";
in
{
  options.profiles.sway.libinput.enable = lib.mkEnableOption "libinput gesture configuration";

  config = lib.mkIf config.profiles.sway.libinput.enable {
    my.home.home.packages = [ pkgs.ydotool ];

    services.gebaar-libinput = let
      # From Linux's kernel input-event-codes.h
      KEY_LEFTMETA = "125";
      KEY_O = "24";
      KEY_I = "23";
      KEY_P = "25";
    in {
      enable = true;

      # Necessary with ydotool now
      ydotoold.enable = true;

      # This configuration is tightly related to my Sway `keybindings.nix`
      # This configuration also uses "natural scrolling" where in
      # swiping and moving your fingers moves the content, not the viewport
      # (like MacOS)
      settings = {
        swipe.commands.four = {
          # Go to next workspace when swiping left with 4 fingers
          # Super_L + o == KEY_LEFTMETA
          left = "${ydotool} key ${KEY_LEFTMETA}:1 ${KEY_O}:1 ${KEY_O}:0 ${KEY_LEFTMETA}:0";
          # Go to previous workspace when swiping right with 4 fingers
          right = "${ydotool} key ${KEY_LEFTMETA}:1 ${KEY_I}:1 ${KEY_I}:0 ${KEY_LEFTMETA}:0";
        };
        swipe.commands.three = {
          # up = "${ydotool} key ${KEY_LEFTMETA}:1 ${KEY_P}:1 ${KEY_P}:0 ${KEY_LEFTMETA}:0";
          right = "${pkgs.sway}/bin/swaymsg focus left";
          left = "${pkgs.sway}/bin/swaymsg focus right";
        };
        swipe.settings = {
          threshold = 0.5;
          one_shot = true;
          trigger_on_release = false;
        };

        ##### Not currently supported by Gebaar
        # # Gesture for Firefox
        # # Go to next page in history when swiping left with 2 fingers
        # gesture swipe left 2  ${ydotool} key Alt_L+Right
        # # Go to previous page in history when swiping right with 2 fingers
        # gesture swipe right 2 ${ydotool} key Alt_L+Left
      };
    };
  };
}
