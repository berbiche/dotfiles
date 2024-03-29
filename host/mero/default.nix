{ config, lib, pkgs, profiles, rootPath, ... }:

{
  imports = with profiles; [
    base
    default-linux
    obs
    steam
    wireguard
    i3
  ] ++ [
    ./openrgb.nix
    ./xserver.nix
  ];

  environment.systemPackages = with pkgs; [];

  my.location = {
    latitude = 45.508;
    longitude = -73.597;
  };

  wireguard."tq.rs".enable = true;
  wireguard."tq.rs".ipv4Address = "10.10.10.121/24";
  wireguard."tq.rs".publicKey = "E6x3s+2OS7hkxZBakUJosZ/zCgNrjjb7LqmeZrhDJz0=";

  profiles.smb.enable = true;
  profiles.smb.secretFile = rootPath + "/secrets/smb-public-share.txt";

  profiles.pipewire.enable = true;
  profiles.pipewire.enableLowLatency = false;
  profiles.pipewire.loopbackTargets = {
    stereo = [
      # "alsa_output.pci-0000_0e_00.4.analog-stereo"
      "alsa_output.usb-Burr-Brown_from_TI_USB_Audio_CODEC-00.analog-stereo-output"
      "alsa_output.usb-SteelSeries_SteelSeries_Arctis_7-00.stereo-game"
    ];
    chat = [
      "alsa_output.usb-Burr-Brown_from_TI_USB_Audio_CODEC-00.analog-stereo-output"
      "alsa_output.usb-SteelSeries_SteelSeries_Arctis_7-00.mono-chat"
    ];
  };

  profiles.steam.wine.enable = true;

  profiles.sway.nvidia.enable = true;

  profiles.i3.flashback.enable = true;

  sops.defaultSopsFile = rootPath + "/secrets/merovingian.yaml";

  boot.kernelParams = [ "amd_iommu=pt" "iommu=soft" ]
  ++ [ "resume_offset=81659904" ]; # Offset of the swapfile

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  boot.kernelPackages = pkgs.linuxPackages_zen;

  # hardware.nvidia.open = true;

  # https://www/spinics.net/lists/usb/msg02644.html
  # Hopefully this will fix usb issues with my nested usb docks
  environment.etc."modprobe.d/custom-usb.conf".text = ''
    options usbcore old_scheme_first=y
    options usbcore use_both_schemes=y
  '';

  hardware.video.hidpi.enable = false;

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
      # My disk is encrypted so enabling the editor isn't that big of a security risk,
      # also if someone has physical access to my computer they have already won.
      editor = true;
      consoleMode = "auto";
    };
  };


  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/136355f2-8296-489d-a311-818fd958100e";
    # https://wiki.archlinux.org/title/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance
    # TLDR: performance improvement on my SSD
    bypassWorkqueues = true;
    allowDiscards = true;
  };

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


  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.package = lib.mkIf (config.hardware.nvidia.open or false) config.boot.kernelPackages.nvidiaPackages.beta;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;

  # services.resolved.enable = lib.mkForce false;

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
    # torrents
    58145
  ];
  networking.firewall.allowedUDPPorts = [
    # Spotify
    57621 57622
    # torrents
    58145
  ];

  systemd.network.links."10-wifi" = {
    matchConfig.MACAddress = "50:e0:85:bf:39:93";
    linkConfig = {
      Name = "wlan0";
    };
  };
  systemd.network.links."10-ethernet" = {
    matchConfig.MACAddress = "b4:2e:99:3f:19:64";
    linkConfig = {
      Name = "ethernet0";
    };
  };

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

  # I know use an old phone as my webcam
  programs.droidcam.enable = true;

  my.home = { config, lib, pkgs, ... }: {
    home.packages = [ pkgs.glpaper pkgs.wf-recorder pkgs.xlockmore ];

    profiles.steam.enableProtonGE = true;

    profiles.i3-sway.notifications = "swaync";
    services.sway-notification-center.settings = {
      fit-to-screen = false;
    };
  };
}
