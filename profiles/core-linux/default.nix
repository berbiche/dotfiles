{ config, pkgs, lib, ... }:

{
  imports = [
    ./boot.nix
    ./services.nix
  ];

  networking.networkmanager.enable = true;

  # Virtualization
  virtualisation.docker.enable = true;

  time.timeZone = "America/Montreal";
  location.provider = "geoclue2";

  networking.firewall.enable = true;
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "9.9.9.9" ];

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
    support32Bit = true;
  };

  # Set automatic hibernation image size to prevent "not enough memory"
  # errors when trying to hibernate, even though the swapfile is as big as
  # the amount of ram I have...
  systemd.tmpfiles.rules = [
    "w /sys/power/image_size - - - - 0"
  ];

  # Add a folder in $XDG_RUNTIME_DIR to be used as my own temporary directory
  my.home = let
    tmpdirs = rec {
      TMP = "\${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/tmp";
      TEMP = TMP;
      TMPDIR = TMP;
      TEMPDIR = TMP;
    };
  in {
    systemd.user.tmpfiles.rules = [
      #Type Path   Mode User Group Age Argument
      "D    %t/tmp 0770 -    -     -   -"
    ];

    systemd.user.sessionVariables = tmpdirs;
    home.sessionVariables = tmpdirs;
  };
}
