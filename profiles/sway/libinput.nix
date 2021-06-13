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
  # Introduce a sleep in every ydotool command for better compatibility with Sway
  ydotool = "${pkgs.ydotool}/bin/ydotool sleep 200 ,";
in
{
  my.home.home.packages = [ pkgs.ydotool ];

  services.gebaar-libinput = {
    enable = true;

    # ydotool.enable = true;

    # This configuration is tightly related to my Sway `keybindings.nix`
    # This configuration also uses "natural scrolling" where in
    # swiping and moving your fingers moves the content, not the viewport
    # (like MacOS)
    settings = {
      swipe.commands.four = {
        # Go to next workspace when swiping left with 4 fingers
        left = "${ydotool} key Super_L+o";
        # Go to previous workspace when swiping right with 4 fingers
        right = "${ydotool} key Super_L+i";
      };
      swipe.commands.three = {
        up = "${ydotool} key Super_L+p";
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
}
