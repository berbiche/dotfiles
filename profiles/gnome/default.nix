{ config, pkgs, ... }:

{
  services.xserver.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs; [
    dconf
    # gnome.gnome-desktop
    gnome.gnome-session
    gnome.gnome-tweaks
    # To install Gnome extensions using the browser extension
    # chrome-gnome-shell
    gnomeExtensions.appindicator
    # Better Gnome Shell
    gnomeExtensions.pop-shell
    ## Broken
    #gnomeExtensions.clipboard-indicator
    gnomeExtensions.dash-to-panel
    # Speedup Gnome animations
    gnomeExtensions.impatience
    # Choose sound output
    gnomeExtensions.sound-output-device-chooser
    # Button to control MPRIS players
    gnomeExtensions.mpris-indicator-button
    # Change theme to dark gtk automatically
    gnomeExtensions.night-theme-switcher
    # Drop-down terminal
    gnomeExtensions.drop-down-terminal
    # Show titlebar in the top bar when a window is maximized
    ## Broken
    #gnomeExtensions.no-title-bar
    # Screenshot tool
    flameshot
    evince
    gnome.eog
  ];

  environment.gnome.excludePackages = with pkgs; [
    gnome-usage
    gnome.accerciser
    evolution
    gnome.cheese
    #gnome.gedit
    gnome.gnome-calculator
    #gnome.gnome-calendar
    gnome.gnome-clocks
    gnome.gnome-contacts
    gnome.gnome-disk-utility
    gnome-tour
    gnome.gnome-logs
    gnome.gnome-music
    gnome-online-accounts
    gnome.gnome-power-manager
    gnome.gnome-software
    gnome.gnome-system-monitor
    gnome.gnome-todo
    gnome-user-docs
    gnome.vinagre
    gnome.yelp
    yelp-tools
  ];
}
