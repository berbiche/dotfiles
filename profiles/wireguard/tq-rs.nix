{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wireguard."tq.rs";
  network = "tqrs";
in
{
  options.wireguard."tq.rs" = {
    enable = mkEnableOption "'tq.rs' Wireguard configuration";
    ipv4Address = mkOption {
      type = types.str;
      example = "10.10.10.4/24";
    };
    publicKey = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    networking.networkmanager.unmanaged = [ network ];

    systemd.network.netdevs.${network} = {
      enable = true;
      netdevConfig = {
        Name = network;
        Kind = "wireguard";
        Description = "wg server dozer.qt.rs";
      };
      wireguardConfig = {
        PrivateKeyFile = "/private/wireguard/zion.key";
      };
      wireguardPeers = map (x: { wireguardPeerConfig = x; }) [{
        # AllowedIPs = [ "10.10.10.0/24" "10.97.1.0/24" "10.97.42.0/24" "10.36.25.0/24" "fc00:23:6::/64" ];
        AllowedIPs = [ "10.10.10.0/24" "10.97.42.0/24" "10.36.25.0/24" "fc00:23:6::/64" ];
        Endpoint = "dozer.qt.rs:51820";
        PersistentKeepalive = 25;
        PresharedKeyFile = "/private/wireguard/zion.preshared";
        PublicKey = "U2ijs3wSSZYizj3x/K/OCYRc6yExETZUOayMFnGYLgs=";
      }];
    };
    systemd.network.networks.${network} = {
      enable = true;
      name = network;
      dns = [ "10.97.42.6" "10.10.10.2" ];
      matchConfig.Name = network;
      networkConfig = {
        Address = cfg.ipv4Address;
        Domains = [ "~tq.rs." "lan." ];
        DNSSEC = false;
      };
      routes = map (x: { routeConfig = x; }) [
        # {
        #   Gateway = "10.10.10.1";
        #   Destination = "10.97.1.0/24";
        #   GatewayOnLink = true;
        # }
        {
          Gateway = "10.10.10.1";
          Destination = "10.97.42.0/24";
          GatewayOnLink = true;
        }
        {
          Gateway = "10.10.10.1";
          Destination = "10.36.25.0/24";
          GatewayOnLink = true;
        }
        {
          Gateway = "10.10.10.1";
          Destination = "10.10.10.0/24";
          GatewayOnLink = true;
        }
      ];
    };
  };
}
