{ config, lib, pkgs, ... }:

{
  imports = [
    ./user.nix
    # ./xserver.nix
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
    # background = pkgs.nixos-artwork.wallpapers.dracula.gnomeFilePath;
    background = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
    greeters.enso = {
      enable = false;
      blur = true;
    };
    greeters.mini = {
      enable = true;
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
        #background-image = "${config.users.users.${config.my.username}.home}/Pictures/wallpaper/current"
      '';
    };
  };

  # To use the gnome-keyring and have it act as the ssh-agent
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  programs.dconf.enable = true;

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
  home-manager.sharedModules = [{
    systemd.user.services.noisetorch = {
      Unit = {
        Description = "noisetorch oneshot loading of microphone suppressor";
        After = lib.optionals config.profiles.pipewire.enable [ "pipewire.service" ]
          ++ lib.optionals config.hardware.pulseaudio.enable [ "pulseaudio.service" ];
        Requisite = lib.optionals config.profiles.pipewire.enable [ "pipewire.service" ]
          ++ lib.optionals config.hardware.pulseaudio.enable [ "pulseaudio.service" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${config.programs.noisetorch.package}/bin/noisetorch -i";
        RemainAfterExit = true;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  }];

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
      google-fonts
      liberation_ttf
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
