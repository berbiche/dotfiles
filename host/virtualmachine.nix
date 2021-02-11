{ config, lib, pkgs, modulesPath, ... }:

let
  profiles = import ../profiles { isLinux = true; };
in
{
  imports = (with profiles; [
    default-linux
    steam
    obs
    gnome
  ]) ++ [
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  boot.kernelParams = [ "console=ttyS0" "console=tty1" "boot.shell_on_fail" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.getty.autologinUser = "${config.my.username}";

  virtualisation.diskSize = 1024 * 2048; # MB
  virtualisation.memorySize = 1024; # MB

  nixpkgs.config.system-features = [ "kvm" ];

  boot.initrd.checkJournalingFS = false;

  networking.firewall.allowPing = true;

  services.openssh.enable = true;
  # services.timesyncd.enable = true;
}
