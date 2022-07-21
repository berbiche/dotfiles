{ config, pkgs, lib, ... }:

{
  homebrew.enable = lib.mkDefault true;
  homebrew.cleanup = lib.mkDefault "uninstall";
  homebrew.brews = [
    "lsusb"
    "pinentry"
    "pinentry-mac"
  ];
  homebrew.casks = [
    "alt-tab"               # Windows-like alt-tab
    # Amphetamine is only available on the App Store
    #"amphetamine"           # Disable automatic sleep when toggled
    "hiddenbar"             # Hide extra things in the top bar
    "karabiner-elements"    # Remap keys
    "keycastr"              # Display typed keys
    "meetingbar"            # Display next meeting in the top bar
    "monitorcontrol"        # DDC control of external displays (brightness, volume, etc.)
    "raycast"               # Spotlight alternative that works with the /nix/store apps
    "rectangle"             # Window-manager on top of Aqua
    "scroll-reverser"       # Inverse scroll for external mouse
  ];
}
