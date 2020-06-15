{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    systemd-boot.enable = false;
    grub = {
      enable = true;
      version = 2;
      enableCryptodisk = true;
      useOSProber = true;
      device = "nodev";
      efiSupport = true;
      # gfxmodeEfi = "1024x768";
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

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/a9cbb95c-523c-4e81-90f1-33b0f4557a32";
      fsType = "ext4";
      options = [ "noatime" "nodiratime" "discard" ];
    };

  boot.initrd.luks.devices."nixos-enc".device = "/dev/disk/by-uuid/5322a183-e08e-4a0a-a6bb-3ecd50516370";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/863b70ab-bf47-433d-b986-d87a9389e19b";
      fsType = "ext4";
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/A54A-B011";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/4881627c-6d34-4add-bc3c-d3a0608370f6"; }
    ];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # High-DPI console
  i18n.consoleFont = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  #systemd.mounts = [
  #  { description = "Games HDD";
  #    what = "/dev/disk/by-uuid/207acdf3-d70a-424b-9e36-fa719639a068";
  #    where = "/mnt/games";
  #    type = "ext4";
  #    options = "defaults";
  #    wantedBy = ["multi-user.target"];
  #  }
  #  { description = "Games HDD automount";
  #    where = "/mnt/games";
  #    wantedBy = ["multi-user.target"];
  #  }
  #];
} //
{
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_CA.UTF-8";
  };

  networking.firewall.allowPing = false;
  #networking.firewall.allowedTCPPorts = [ 8000 ];

  environment.systemPackages = [ pkgs.brightnessctl ];

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
    ];
  };
}
