{ config, lib, pkgs, ... }:

let
  profiles = import ../profiles;
in
{
  imports = [
    profiles.default-linux
    profiles.steam
    profiles.wireguard
  ];

  hardware.enableRedistributableFirmware = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  boot.plymouth.enable = true;
  boot.loader = {
    timeout = 10;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    systemd-boot = {
      enable = true;
      # My disk is encrypted so editor isn't that big of a security risk
      editor = true;
      consoleMode = "auto";
    };
  };

  # services.logind.lidSwitch = "ignore";

  # boot.initrd.luks = {
  #  cryptoModules = [ "aes" "xts" "sha512" ];
  #  yubikeySupport = true;
  #  devices = [ {
  #    name = "nixos-enc";
  #    preLVM = false;
  #    yubikey = {
  #      slot = 2;
  #      twoFactor = false;
  #      storage.device = "/dev/disk/by-partuuid/f6a9cde0-5728-46d1-aaa3-eae945f76aae";
  #    };
  #  } ];
  # };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/a9cbb95c-523c-4e81-90f1-33b0f4557a32";
      fsType = "ext4";
      options = [ "noatime" "nodiratime" "discard" ];
    };

  boot.initrd.luks.devices."nixos-enc" = {
    device = "/dev/disk/by-uuid/5322a183-e08e-4a0a-a6bb-3ecd50516370";
    preLVM = true;
    allowDiscards = true;
  };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/A54A-B011";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/4881627c-6d34-4add-bc3c-d3a0608370f6"; }
    ];

  nix.maxJobs = 6;
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  # High-DPI console
  # console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
  # console.keyMap = "us";
  i18n.defaultLocale = "en_CA.UTF-8";

  networking.firewall.allowPing = true;
  #networking.firewall.allowedTCPPorts = [ 8000 ];

  environment.systemPackages = [ pkgs.brightnessctl ];

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

  services.printing.drivers = [ pkgs.hplip ];

  # X11 fixes for the tearing and low performance
  services.xserver.useGlamor = true;
  services.xserver.videoDrivers = lib.mkForce [ "modesettings" ];
  services.xserver.deviceSection = ''
    Option "DRI" "3"
    Option "TearFree" "true"
  '';

  my.home.my.identity = {
    gpgSigningKey = "74100A15021CC2857DF868D831D89C1E266CFDC8";
  };
}
