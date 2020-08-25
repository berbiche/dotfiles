{ config, pkgs, lib, ... }:

{
  imports = [
    ./boot.nix
    ./zsh.nix
    ./services.nix
    ./all-packages.nix
  ];

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
  users.users.${config.my.username} = {
    createHome = true;
    isNormalUser = true;
    shell = pkgs.zsh;
    uid = 1000;
    group = config.my.username;
    home = "/home/${config.my.username}";
    extraGroups = [ "wheel" "networkmanager" "input" "audio" "video" "docker" "dialout" ];
  };
  users.groups.${config.my.username} = { };
}
