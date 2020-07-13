{ config, lib, pkgs, ... }:

{
  imports = [
    ./graphical/sway.nix
    # ./graphical/gnome.nix
    ./graphical/kde.nix
    ./graphical/steam.nix
  ];

  environment.systemPackages = [ pkgs.playerctl pkgs.polkit pkgs.polkit_gnome ];


  services.xserver.enable = true;
  #services.xserver.tty = 1;
  services.xserver.displayManager.defaultSession = "sway";

  services.xserver.displayManager.lightdm = {
    enable = true;
    autoLogin = {
      enable = false;
      user = config.my.username;
      timeout = 5;
    };
    greeters.enso = {
      enable = true;
      blur = true;
    };
  };

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
    enablePepperFlash = true;
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
      hinting.enable = false;
      cache32Bit = true;
      defaultFonts = {
        serif = [ "Ubuntu" ];
        sansSerif = [ "Ubuntu" ];
        monospace = [ "Ubuntu" ];
      };
    };
  };

}
