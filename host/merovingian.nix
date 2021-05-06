{ config, lib, pkgs, profiles, ... }:

{
  imports = with profiles; [
    base
    default-linux
    steam
    obs
    gnome
    wireguard
  ];

  wireguard."tq.rs".enable = false;
  wireguard."tq.rs".ipv4Address = "10.10.10.121/24";
  wireguard."tq.rs".publicKey = "E6x3s+2OS7hkxZBakUJosZ/zCgNrjjb7LqmeZrhDJz0=";

  profiles.pipewire.enable = true;

  boot.kernelParams = [ "amd_iommu=pt" "iommu=soft" ]
    ++ [ "resume_offset=81659904" ]; # Offset of the swapfile

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  boot.kernelPackages = pkgs.linuxPackages_zen;
  #boot.kernelPackages = pkgs.linuxPackages_latest;

  # Disable HDMI/DisplayPort audio with amdgpu
  environment.etc."modprobe.d/custom-amdgpu.conf".text = ''
    options amdgpu audio=0
    # 10-bit colors lack hw accel on Chromium, and glitches with Mesa/Vulkan
    # options amdgpu deep_color=1

    # DSC still not working with my samsung monitor
    #options amdgpu dc=0
  '';

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  # Boot loader settings
  # Resume device is the partition with the swapfile in this case
  boot.resumeDevice = "/dev/mapper/cryptroot";
  # Show Nixos logo while loading
  boot.plymouth.enable = false;
  boot.loader = {
    timeout = 10;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    systemd-boot = {
      enable = true;
      # My disk is encrypted so enabling the editor isn't that big of a security risk
      # If someone has physical access to my computer they have already won.
      editor = true;
      consoleMode = "auto";
      # consoleMode = "keep";
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
  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/7F25-9A66";
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
    size = 32768;
  }];

  nix.maxJobs = lib.mkDefault 16;

  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;

  services.resolved.enable = lib.mkForce false;

  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-runtime
    amdvlk
  ];

  networking.firewall.allowPing = true;
  # Open ports in the firewall.
  # Chromium chromecast (port 8010)
  # https://github.com/NixOS/nixpkgs/issues/49630
  networking.firewall.allowedTCPPorts = [
    # No idea
    1716
    8010
    21027
    # Spotify
    57621 57622
  ];
  networking.firewall.allowedUDPPorts = [
    # Spotify
    57621 57622
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemuPackage = pkgs.qemu_kvm;
  };
  environment.systemPackages = with pkgs; [ vagrant freenect ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";
  console.font = "Lat2-Terminus16";
  console.keyMap = "us";

  services.printing.drivers = [ pkgs.hplip ];

  # Enable xbox controller
  hardware.xpadneo.enable = true;
}
