{ config, lib, pkgs, ... }:

{
  imports = [
    ./user.nix
    ./dconf.nix
    ./noisetorch.nix
    ./fonts.nix
    # ./opensnitch.nix
    # ./xserver.nix
  ];

  environment.systemPackages = with pkgs; lib.mkMerge [
    [
      polkit
      polkit_gnome
      (hunspellWithDicts [
        hunspellDicts.en_CA-large
        hunspellDicts.fr-any
      ])
    ]
    (lib.mkIf config.networking.networkmanager.enable [
      networkmanagerapplet
    ])
  ];

  services.xserver.enable = true;
  services.xserver.displayManager.lightdm = {
    enable = true;
    # background = pkgs.nixos-artwork.wallpapers.dracula.gnomeFilePath;
    background = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
    greeters.enso = {
      enable = true;
      blur = true;
    };
    greeters.mini = {
      enable = false;
      user = config.my.username;
      extraConfig = ''
        [greeter]
        show-password-label = true
        show-image-on-all-monitors = true
        password-input-width = 40

        [greeter-hotkeys]
        session-key = e

        [greeter-theme]
        background-image-size = contain
      '';
    };
  };

  # To use the gnome-keyring and have it act as the ssh-agent
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  services.xserver.libinput.enable = true;
  services.xserver.layout = "us";

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ libva ];
  };

  # Authorization prompt for wheel/root actions
  # for things that support polkit
  security.polkit.enable = true;

  services.flatpak.enable = false;
  xdg = {
    icons.enable = true;
    portal.enable = true;
    portal.gtkUsePortal = true;
  };

  services.printing.enable = true;

  # Discover devices on local network (printers, etc.)
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.printing.browsing = true;

  # Bluetooth
  services.blueman.enable = true;
  home-manager.sharedModules = [{ services.mpris-proxy.enable = true; }];

  # Logitech
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
}
