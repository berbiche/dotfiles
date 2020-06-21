{ config, pkgs, lib, ... }:

with builtins;
let
  pwd = toString ./.;
  sources = import ./nix/sources.nix;
  overlay = import ./overlays.nix;
in
{
  imports = (map (x: ./nixos + "/${x}") [
    "hardware-configuration.nix"
    # "cachix.nix"
    "zsh.nix"
    "graphical.nix"
    "all-packages.nix"
    "services.nix"
  ]) ++ [
    "${sources.home-manager}/nixos"
  ];

  options = with lib; with lib.types; {
    username = mkOption {
      type = str;
      description = "Primary user username";
      example = "nicolas";
      readOnly = true;
    };

    hostname = mkOption {
      type = str;
      description = "System hostname";
      readOnly = true;
    };

    userHomeConfiguration = mkOption {
      type = either path str;
      example = literalExample "./user/home.nix";
      description = "Path to the home-manager user configuration";
      readOnly = true;
    };
  };


  config = lib.mkMerge [
    {
      nixpkgs.overlays = [ overlay ];

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
      nix.trustedUsers = [ "root" config.username ];
      # Define the nixos-config path to the current folder
      # nix.nixPath =
      #   [
      #     "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      #     "nixos-config=${pwd}/configuration.nix"
      #     "/nix/var/nix/profiles/per-user/root/channels"
      #   ];

      networking.hostName = config.hostname;
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
        extraGroups = [ "wheel" "networkmanager" "input" "audio" "video" "docker" "vboxusers" "dialout" ];
      };

      home-manager = {
        users."${config.username}" = config.userHomeConfiguration;
        useUserPackages = true;
        useGlobalPkgs = true;
        verbose = true;
      };
    }
  ];
}
