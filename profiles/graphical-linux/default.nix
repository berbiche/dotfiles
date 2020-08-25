{ config, lib, pkgs, ... }:

{
  imports = [
    ./user.nix
    ./graphical/sway.nix
    ./graphical/kde.nix
    ./graphical/steam.nix
  ];

  environment.systemPackages = [ pkgs.playerctl pkgs.polkit pkgs.polkit_gnome ];


  services.xserver.enable = true;
  #services.xserver.tty = 1;
  services.xserver.displayManager.autoLogin = {
    # Disabled until automatic unlock of my Gnome Keyring works
    enable = false;
    user = config.my.username;
  };
  services.xserver.displayManager.lightdm = {
    enable = true;
    greeters.enso = {
      enable = true;
      blur = true;
    };
  };

  services.gnome3.gnome-keyring.enable = true;

  services.xserver.libinput.enable = true;
  services.xserver.layout = "us";

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ libva ];
  };


  security.polkit.enable = true;

  services.flatpak.enable = true;
  xdg = {
    icons.enable = true;
    portal.enable = true;
    portal.gtkUsePortal = true;
  };

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];

  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.printing.browsing = true;

  nixpkgs.config.chromium = {
    enableWideVine = true;
    enableVaapi = true;
    enablePepperFlash = false;
  };

  fonts = {
    enableFontDir = true;
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
