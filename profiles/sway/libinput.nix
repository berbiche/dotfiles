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

  # This configuration is tightly related to my Sway `keybindings.nix`
  # This configuration also uses "natural scrolling" where in
  # swiping and moving your fingers moves the content, not the viewport
  # (like MacOS)
  configFile = pkgs.writeTextDir "gebaar/gebaard.toml" ''
    # I'm only using this configuration with a computer with a single touchpad
    # so I don't care about matching all touchpads
    device all

    # Go to next workspace when swiping left with 4 fingers
    gesture swipe left  4 ${ydotool} key Super_L+o
    # Go to previous workspace when swiping right with 4 fingers
    gesture swipe right 4 ${ydotool} key Super_L+i

    # Gesture for Firefox
    # Go to next page in history when swiping left with 2 fingers
    gesture swipe left 2  ${ydotool} key Alt_L+Right
    # Go to previous page in history when swiping right with 2 fingers
    gesture swipe right 2 ${ydotool} key Alt_L+Left

    # [swipe.commands.four]
    # left = "${ydotool} key Super_L+o"
    # right = "${ydotool} key Super_L+i"

    # [swipe.commands.three]
    # up = "${ydotool} key Super_L+p"
  '';
in
{
  my.home.home.packages = [ pkgs.ydotool ];

  # https://github.com/NixOS/nixpkgs/issues/70471
  # Chown&chmod /dev/uinput to owner:root group:input mode:0660
  boot.kernelModules = [ "uinput" ];
  services.udev.extraRules = ''
    SUBSYSTEM=="misc", KERNEL=="uinput", TAG+="uaccess", OPTIONS+="static_node=uinput", GROUP="input", MODE="0660"
  '';

  users.users.libinput-gestures = {
    group = "input";
    description = "libinput gestures/gebaard user";
    isSystemUser = true;
    inherit (config.users.users.nobody) home;
  };

  systemd.services.libinput-gestures = {
    description = "Touchpad gesture listener";
    reloadIfChanged = true;

    partOf = [ "graphical.target" ];
    requires = [ "graphical.target" ];
    after = [ "graphical.target" ];
    wantedBy = [ "graphical.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.libinput-gestures}/bin/libinput-gestures -c ${configFile}/gebaar/gebaard.toml";
      #ExecStart = "${pkgs.gebaar-libinput}/bin/gebaard";
      #Environment = [ ''"XDG_CONFIG_HOME=${configFile}"'' ];
      User = config.users.users.libinput-gestures.name;
      Group = config.users.users.libinput-gestures.group;
    };
  };
}
