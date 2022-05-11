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

  systemd.network.wait-online.timeout = 10;
  systemd.network.wait-online.anyInterface = true;

  # Set automatic hibernation image size to prevent "not enough memory"
  # errors when trying to hibernate, even though the swapfile is as big as
  # the amount of ram I have...
  systemd.tmpfiles.rules = let
    my-uid = toString config.users.users.${config.my.username}.uid;
  in [
    #Type Path                  Mode User      Group     Age Argument
    "w    /sys/power/image_size -    -         -         -   0"
    "d    %T/user               0777 0         0         -   -"
    "d    %T/user/${my-uid}     0770 ${my-uid} ${my-uid} -   -"
  ];

  # Set default dns servers
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" "1.0.0.1" "8.8.4.4" "9.9.9.9" ];

  # Add a folder in $TMP/user/$UID to be used as my own temporary directory
  home-manager.sharedModules = [
    (let
      tmpdirs = rec {
        # Nix attributes are ordered by name and TMP needs to be at the top
        " TMP" = "/tmp/user/$(id -u)";
        TEMP = "/tmp/user/$(id -u)/";
        TMP = "$TEMP";
        TMPDIR = "$TEMP";
        TEMPDIR = "$TEMP";
      };
    in {
      systemd.user.sessionVariables = tmpdirs;
      home.sessionVariables = tmpdirs;
    })
  ];
}
