{ config, lib, pkgs, ... }:

{
  imports = [
    ./graphical/sway.nix
    ./graphical/gnome.nix
    #./graphical/kde.nix
    ./graphical/steam.nix
  ];

  environment.systemPackages = [ pkgs.playerctl pkgs.polkit pkgs.polkit_gnome ];


  services.xserver.enable = true;
  #services.xserver.tty = 1;
  services.xserver.displayManager.defaultSession = "sway";

  services.xserver.displayManager.lightdm = {
    enable = true;
    #theme = "chili";
    autoLogin = {
      enable = true;
      user = "nicolas";
      timeout = 5;
    };
    greeters.enso.enable = true;
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
      anonymousPro
      google-fonts
      inconsolata-nerdfont
      liberation_ttf
      noto-fonts
      noto-fonts-emoji
      nerdfonts
      hasklig
      powerline-fonts
      source-code-pro
      terminus-nerdfont
      ttf_bitstream_vera
      ubuntu_font_family
    ];

    fontconfig = {
      enable = true;
      hinting.enable = false;
      cache32Bit = true;
    };
  };

}
