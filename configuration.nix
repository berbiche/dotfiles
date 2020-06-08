{ config, pkgs, lib, ... }:

with builtins;
let
  host = lib.fileContents ./hostname;
  username = "nicolas";
  home-manager-configuration = ./user/home.nix;

  pwd = toString ./.;

  c = {
    inherit username;

    # This value determines the NixOS release with which your system is to be
    # compatible, in order to avoid breaking some software such as database
    # servers. You should change this only after NixOS release notes say you
    # should.
    system.stateVersion = "20.09"; # Did you read the comment?

    boot.cleanTmpDir = true;

    # Automatic GC of nix files
    nix.gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 10d";
    };

    environment.systemPackages = [ pkgs.cachix ];
    nix.trustedUsers = [ config.username "root" ];
    # Define the nixos-config path to the current folder
    nix.nixPath =
      [
        "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
        "nixos-config=${pwd}/configuration.nix"
        "/nix/var/nix/profiles/per-user/root/channels"
      ];

    networking.hostName = host; # Define your hostname.
    networking.networkmanager.enable = true;

    # Virtualization
    virtualisation.docker.enable = true;

    time.timeZone = "America/Montreal";
    location.provider = "geoclue2";

    networking.firewall.enable = true;
    networking.nameservers = [ "1.1.1.1" "8.8.8.8" "9.9.9.9" ];

    # Enable sound.
    sound.enable = true;
    hardware.pulseaudio = {
      enable = true;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      package = pkgs.pulseaudioFull;
      support32Bit = true;
    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${config.username} = {
      isNormalUser = true;
      shell = pkgs.zsh;
      uid = 1000;
      group = config.username;
      home = "/home/${config.username}";
      extraGroups = [ "wheel" "networkmanager" "input" "audio" "video" "docker" "vboxusers" ];
    };
    home-manager.users.${config.username} = home-manager-configuration;
    home-manager.useUserPackages = true;
  };
in
{
  imports =
    [ <nixpkgs/nixos/modules/hardware/all-firmware.nix>
      <home-manager/nixos>
      ./overlays
    ] ++ map (x: ./top-level + "/${x}") [
      "hardware-configuration.nix"
      "cachix.nix"
      "zsh.nix"
      "graphical.nix"
      "all-packages.nix"
      "services.nix"
      "host/${host}.nix"
    ];

  options.username = lib.mkOption {
    description = "The primary user username";
    type = lib.types.str;
  };

  config = c;
}
