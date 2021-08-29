{ config, lib, pkgs, ... }:

{
  imports = [
    ./user.nix
    ./xserver.nix
  ];

  environment.systemPackages = with pkgs; [
    polkit
    polkit_gnome
    (hunspellWithDicts [
      hunspellDicts.en_CA-large
      hunspellDicts.fr-any
    ])
  ];

  services.xserver.enable = true;
  services.xserver.displayManager.lightdm = {
    enable = true;
    greeters.enso = {
      enable = true;
      blur = true;
    };
  };

  services.xserver.dpi = lib.mkForce null;

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

  services.flatpak.enable = true;
  xdg = {
    icons.enable = true;
    portal.enable = true;
    portal.gtkUsePortal = true;
  };

  services.printing.enable = true;

  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.printing.browsing = true;

  services.blueman.enable = true;

  # Logitech
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  # Microphone noise remover
  programs.noisetorch.enable = true;

  nixpkgs.config.chromium = {
    enableWideVine = true;
    enableVaapi = true;
    enablePepperFlash = false;
  };

  fonts = {
    fontDir.enable = true;
    enableDefaultFonts = true;

    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      ubuntu_font_family
      anonymousPro
      source-code-pro
      google-fonts
      liberation_ttf
      nerdfonts
      hasklig
      powerline-fonts
      ttf_bitstream_vera
    ];

    fontconfig = {
      enable = true;
      hinting.enable = true;
      cache32Bit = true;
      defaultFonts = {
        serif = [ "Ubuntu" ];
        sansSerif = [ "Ubuntu" ];
        monospace = [ "Ubuntu" ];
      };
    };
  };
}
