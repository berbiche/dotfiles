{ config, pkgs, lib, ... }:

{
  imports = [
    ./boot.nix
    ./services.nix
    ./yubikey.nix
  ];

  networking.networkmanager.enable = true;

  # Virtualization
  # virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;
  # virtualisation.podman.dockerCompat = true;
  virtualisation.podman.defaultNetwork.dnsname.enable = true;

  networking.firewall.enable = true;

  # Set automatic hibernation image size to prevent "not enough memory"
  # errors when trying to hibernate, even though the swapfile is as big as
  # the amount of ram I have...
  systemd.tmpfiles.rules = [
    #Type Path                  Mode User Group Age Argument
    "w    /sys/power/image_size -    -    -     -   0"
    "d    %T/user               0777 0    0     -   -"
  ];

  # Set default dns servers
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" "1.0.0.1" "8.8.4.4" "9.9.9.9" ];

  # Add a folder in $TMP/user/$UID to be used as my own temporary directory
  home-manager.sharedModules = [
    (let
      tmpdirs = rec {
        TMP = "/tmp/user/$(id -u)/";
        TEMP = TMP;
        TMPDIR = TMP;
        TEMPDIR = TMP;
      };
    in {
      systemd.user.tmpfiles.rules = [
        #Type Path         Mode User Group Age Argument
        "D    /tmp/user/%U 0770 -    -     -   -"
      ];
      systemd.user.sessionVariables = tmpdirs;
      home.sessionVariables = tmpdirs;
    })
  ];
}
