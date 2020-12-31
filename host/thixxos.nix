{ config, lib, pkgs, ... }:

let
  profiles = import ../profiles;
in
{
  imports = [ profiles.default-linux profiles.steam ];

  hardware.enableRedistributableFirmware = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

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

  nix.maxJobs = 6;
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  # High-DPI console
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
  console.keyMap = "us";
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

  networking.networkmanager.unmanaged = [ "wg0" ];
  systemd.network.enable = true;
  systemd.network.netdevs.wg0 = {
    enable = true;
    netdevConfig = {
      Name = "wg0";
      Kind = "wireguard";
      Description = "wg server dozer.qt.rs";
    };
    wireguardConfig = {
      PrivateKeyFile = "/private/wireguard/zion.key";
    };
    wireguardPeers = map (x: { wireguardPeerConfig = x; }) [{
      AllowedIPs = [ "10.10.10.0/24" "192.168.0.0/24" "fc00:23:6::/64" ];
      Endpoint = "dozer.qt.rs:51820";
      PersistentKeepalive = 25;
      PresharedKeyFile = "/private/wireguard/zion.preshared";
      PublicKey = "U2ijs3wSSZYizj3x/K/OCYRc6yExETZUOayMFnGYLgs=";
    }];
  };
  systemd.network.networks.wg0 = {
    enable = true;
    name = "wg0";
    dns = [ "10.10.10.3" ];
    matchConfig.Name = "wg0";
    networkConfig = {
      Address = "10.10.10.4/24";
      DNS = [ "192.168.0.3" "10.10.10.3" ];
      Domains = [ "~tq.rs." "~kifinti.lan." ];
    };
    routes = map (x: { routeConfig = x; }) [
      {
        Gateway = "10.10.10.1";
        Destination = "192.168.0.0/24";
        GatewayOnLink = true;
      }
      {
        Gateway = "10.10.10.1";
        Destination = "10.10.10.0/24";
        GatewayOnLink = true;
      }
    ];
  };
  system.activationScripts.configure-wireguard-permissions = ''
    mkdir -p /private/wireguard
    echo "Setting Wireguard folder permissions"
    chmod -c 0755 /private /private/wireguard
    chmod -c 0440 /private/wireguard/*
    chown -cR root:systemd-network /private/wireguard
  '';
}
