{ config, pkgs, ... }:

{
  services.xserver.desktopManager.gnome3.enable = true;

  environment.systemPackages = with pkgs; [
    gnome3.dconf
    gnome3.gnome-desktop
    gnome3.gnome-session
    gnome3.gnome-tweaks
    # To install Gnome extensions using the browser extension
    chrome-gnome-shell
    gnomeExtensions.appindicator
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
  ];
  
  environment.gnome3.excludePackages = with pkgs; [
    gnome-usage
    gnome3.accerciser
    gnome3.cheese
    gnome3.evolution
    #gnome3.gedit
    gnome3.gnome-calculator
    #gnome3.gnome-calendar
    gnome3.gnome-clocks
    gnome3.gnome-contacts
    gnome3.gnome-disk-utility
    gnome3.gnome-getting-started-docs
    gnome3.gnome-logs
    gnome3.gnome-music
    gnome3.gnome-online-accounts
    gnome3.gnome-power-manager
    gnome3.gnome-software
    gnome3.gnome-system-monitor
    gnome3.gnome-todo
    gnome3.gnome-user-docs
    gnome3.vinagre
    gnome3.yelp
    gnome3.yelp-tools
  ];
}
