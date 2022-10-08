{ config, lib, pkgs, profiles, rootPath, ... }:

{
  imports = with profiles; [
    base
    default-linux
    obs
    steam
    wireguard
  ];

  environment.systemPackages = [
    pkgs.intel-gpu-tools # sudo intel_gpu_top
  ];

  my.location = {
    latitude = 45.508;
    longitude = -73.597;
  };

  wireguard."tq.rs".enable = true;
  wireguard."tq.rs".ipv4Address = "10.10.10.4/24";
  wireguard."tq.rs".publicKey = "U2ijs3wSSZYizj3x/K/OCYRc6yExETZUOayMFnGYLgs=";

  profiles.smb.enable = true;
  profiles.smb.secretFile = rootPath + "/secrets/smb-public-share.txt";

  profiles.pipewire.enable = true;

  hardware.enableRedistributableFirmware = true;
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackages_zen;
  # Fix randomly high CPU usage when connected to a thunderbolt 3 dock
  boot.kernelParams = [ "acpi_mask_gpe=0x69" ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.supportedFilesystems = [ "ntfs" ];

  # Hibernate after sleeping in suspend mode for 30 minutes
  systemd.sleep.extraConfig = ''
    HandleSuspendKey=suspend-then-hibernate
    HandleHibernateKey=suspend-then-hibernate
    HandleLidSwitch=suspend-then-hibernate
    HibernateDelaySec=30min
  '';
  # services.logind.lidSwitch = "ignore";

  # high-resolution display
  hardware.video.hidpi.enable = true;
  # I only use X for lightdm, so I can set it globally here instead.
  services.xserver.dpi = 192;
  boot.kernel.sysctl."dev.i915.perf_stream_paranoid" = 0;

  boot.plymouth.enable = true;
  boot.loader = {
    timeout = 10;
    efi = {
      canTouchEfiVariables = true;
    };
    systemd-boot = {
      enable = true;
      # My disk is encrypted so editor isn't that big of a security risk
      editor = true;
      # Hidpi screen, use the 80x50 console mode for a bigger font
      # This is the only way to do it atm with systemd-boot
      consoleMode = "1";
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";
  console.font = "Lat2-Terminus16";
  console.keyMap = "us";

  time.timeZone = "America/Montreal";
  # time.timeZone = "Europe/Prague";
  location.provider = "manual";

  services.btrfs.autoScrub.enable = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "subvol=nixos" "compress=zstd" "noatime" "nodiratime" "discard" ];
  };

  boot.initrd.luks.devices."nixos-enc" = {
    device = "/dev/disk/by-partlabel/nixos-enc";
    allowDiscards = true;
    # https://wiki.archlinux.org/title/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance
    # TLDR: performance improvement on my SSD
    bypassWorkqueues = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A54A-B011";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "subvol=nixos/home" "compress=zstd" "noatime" "nodiratime" "discard" ];
  };

  fileSystems."/private" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "subvol=nixos/private" "compress=zstd" "noatime" "nodiratime" "discard" ];
  };

  nix.settings.max-jobs = 6;
  powerManagement.enable = true;
  powerManagement.powertop.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";
  # powerManagement.cpuFreqGovernor = "performance";
  services.thermald.enable = true;

  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [
    # Can't remember
    1716
    # Chromium chromecast (port 8010)
    # https://github.com/NixOS/nixpkgs/issues/49630
    8010
    # Can't remember
    9000 9001 9002
    # Can't remember
    21027
    # Spotify
    57621 57622
  ];
  networking.firewall.allowedUDPPorts = [
    # Spotify
    57621 57622
  ];

  systemd.network.links."10-wifi" = {
    matchConfig.MACAddress = "3c:6a:a7:d4:e0:90";
    linkConfig = {
      Name = "wlan0";
    };
  };
  systemd.network.links."10-ethernet" = {
    matchConfig.MACAddress = "48:2a:e3:10:9d:0d";
    linkConfig = {
      Name = "ethernet0";
    };
  };


  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
    ];
  };

  virtualisation.libvirtd = {
    enable = true;
    # qemu.package = pkgs.qemu_kvm;
    qemu.runAsRoot = false;
  };

  services.printing.drivers = [ pkgs.hplip ];

  # X11 fixes for the tearing and low performance
  # Doesn't seem to be working ¯\_(ツ)_/¯
  services.xserver.videoDrivers = lib.mkForce [ "modesettings" ];
  services.xserver.deviceSection = ''
    Option "DRI" "3"
    Option "TearFree" "true"
  '';

  # Xbox One S bluetooth controller support
  hardware.xpadneo.enable = true;

  # Brightness control based on ambient light level
  services.clight.enable = false;

  my.home = { config, lib, pkgs, ... }: {
    profiles.steam.enableProtonGE = true;
    # I wish gammastep was smart enough to figure out the backend automatically...
    services.gammastep.settings.general.adjustment-method = "wayland";
  };
}
