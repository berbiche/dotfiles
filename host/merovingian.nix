{ config, lib, pkgs, ... }:

let
  profiles = import ../profiles;
in
{
  imports = [ profiles.default-linux profiles.steam ];

  boot.kernelParams = [ "amd_iommu=pt" "iommu=soft" ]
    ++ [ "resume_offset=63195136" ]; # Offset of the swapfile

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Boot loader settings
  # Resume device is the partition with the swapfile in this case
  boot.resumeDevice = "/dev/mapper/cryptroot";
  # Show Nixos logo while loading
  boot.plymouth.enable = true;
  boot.loader = {
    timeout = null;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    grub = {
      enable = true;
      enableCryptodisk = true;
      useOSProber = true;
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = false;
    };
  };

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/136355f2-8296-489d-a311-818fd958100e";
    preLVM = true;
    allowDiscards = true;
  };

  # FS settings
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/05b0f515-f901-4bf3-afa9-f155cdc7ae7e";
      fsType = "ext4";
      options = [ "noatime" "nodiratime" "discard" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/6b8e779b-838a-433e-992c-e28ee70c7207";
      fsType = "ext4";
      options = [ "noatime" "nodiratime" "discard" ];
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/2B3C-E2E7";
      fsType = "vfat";
    };

  fileSystems."/mnt/games" =
    { device = "/dev/disk/by-uuid/D896285496283602";
      fsType = "ntfs";
      options = [ "auto" "nofail" "remove_hiberfile" "noatime" "nodiratime" "uid=1000" "gid=1000" "dmask=007" "fmask=007" "big_writes" ];
    };

  swapDevices = [{
    device = "/swapfile";
    #priority = 0;
    size = 16384;
  }];

  nix.maxJobs = lib.mkDefault 16;

  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;

  environment.systemPackages = with pkgs; [
    dislocker
  ];

  networking.firewall.allowPing = true;
  # Open ports in the firewall.
  # Chromium chromecast (port 8010)
  # https://github.com/NixOS/nixpkgs/issues/49630
  networking.firewall.allowedTCPPorts = [ 1716 8010 21027 ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  virtualisation.libvirtd.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";
  console.font = "Lat2-Terminus16";
  console.keyMap = "us";
}
