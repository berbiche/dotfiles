{ config, lib, pkgs, profiles, rootPath, ... }:

{
  imports = with profiles; [
    base
    default-linux
    obs
    steam
    wireguard
  ] ++ [
    ./openrgb.nix
  ];

  environment.systemPackages = with pkgs; [];

  wireguard."tq.rs".enable = false;
  wireguard."tq.rs".ipv4Address = "10.10.10.121/24";
  wireguard."tq.rs".publicKey = "E6x3s+2OS7hkxZBakUJosZ/zCgNrjjb7LqmeZrhDJz0=";

  profiles.smb.enable = true;
  profiles.smb.secretFile = rootPath + "/secrets/smb-public-share.txt";

  profiles.pipewire.enable = true;
  profiles.pipewire.enableLowLatency = true;
  profiles.pipewire.loopbackTargets = [
    "alsa_output.pci-0000_0e_00.4.analog-stereo"
    "alsa_output.usb-SteelSeries_SteelSeries_Arctis_7-00.stereo-game"
  ];

  profiles.steam.wine.enable = true;

  sops.defaultSopsFile = rootPath + "/secrets/merovingian.yaml";

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

  # https://www/spinics.net/lists/usb/msg02644.html
  # Hopefully this will fix usb issues with my nested usb docks (4 level of nesting)
  # Sometimes I can't use my keyboard when booting because usb read errors
  environment.etc."modprobe.d/custom-usb.conf".text = ''
    options usbcore old_scheme_first=y
    options usbcore use_both_schemes=y
  '';

  # Hide devices from Nemo/Nautilus
  services.udev.extraRules = ''
     SUBSYSTEM=="block", ENV{ID_FS_UUID}=="7F25-9A66", ENV={UDISKS_IGNORE}="1"
  '';

  hardware.video.hidpi.enable = false;

  # Boot loader settings
  # Resume device is the partition with the swapfile in this case
  boot.resumeDevice = "/dev/mapper/cryptroot";
  # Show Nixos logo while loading
  boot.plymouth.enable = true;
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
    # https://wiki.archlinux.org/title/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance
    # TLDR: performance improvement on my SSD
    bypassWorkqueues = true;
    allowDiscards = true;
  };

  boot.initrd.luks.devices."blackarch" = {
    device = "/dev/disk/by-partlabel/blackarch_enc";
    # TLDR: performance improvement on my SSD
    bypassWorkqueues = true;
    allowDiscards = true;
  };
  system.activationScripts."blackarch-permissions".text = ''
    echo "chowning /dev/mapper/blackarch to qemu-libvirtd:libvirtd"
    if [ -b /dev/mapper/blackarch ]; then
      chown -v qemu-libvirtd:libvirtd /dev/mapper/blackarch
      if [ $? -ne 0 ]; then
        echo "Failed to chown /dev/mapper/blackarch"
      fi
    else
      echo "could not chown /dev/mapper/blackarch"
    fi
  '';

  # FS settings
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/05b0f515-f901-4bf3-afa9-f155cdc7ae7e";
    fsType = "ext4";
    options = [ "noatime" "nodiratime" "discard" ];
  };
  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/7F25-9A66";
    fsType = "vfat";
  };
  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/D896285496283602";
    fsType = "ntfs";
    options = [ "auto" "nofail" "noatime" "nodiratime" "uid=1000" "gid=1000" "dmask=007" "fmask=007" "big_writes" ];
  };
  fileSystems."/mnt/fast and furious" = {
    device = "/dev/disk/by-uuid/700451CB045194C6";
    fsType = "ntfs";
    options = [ "auto" "nofail" "noatime" "nodiratime" "discard" "uid=1000" "gid=1000" "dmask=007" "fmask=007" "big_writes" ];
  };

  swapDevices = [{
    device = "/swapfile";
    #priority = 0;
    size = 32768;
  }];

  nix.settings.max-jobs = lib.mkDefault 16;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";
  console.font = "Lat2-Terminus16";
  console.keyMap = "us";

  time.timeZone = "America/Montreal";
  location.provider = "manual";


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

  services.openssh.enable = true;
  services.openssh.openFirewall = true;
  services.openssh.permitRootLogin = "no";
  services.openssh.passwordAuthentication = false;

  virtualisation.libvirtd = {
    enable = true;
    qemu.package = pkgs.qemu_kvm;
    qemu.runAsRoot = false;
  };

  services.printing.drivers = [ pkgs.hplip ];

  # Enable xbox controller
  hardware.xpadneo.enable = true;

  my.home = { config, lib, pkgs, ... }: {
    home.packages = [ pkgs.glpaper pkgs.wf-recorder ];

    profiles.steam.enableProtonGE = true;
  };
}
