{ config, pkgs, ... }:

let
  network = "tqrs";
in
{
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
      AllowedIPs = [ "10.10.10.0/24" "192.168.0.0/24" "fc00:23:6::/64" ];
      Endpoint = "dozer.qt.rs:51820";
      PersistentKeepalive = 25;
      PresharedKeyFile = "/private/wireguard/zion.preshared";
      PublicKey = "U2ijs3wSSZYizj3x/K/OCYRc6yExETZUOayMFnGYLgs=";
    }];
  };
  systemd.network.networks.${network} = {
    enable = true;
    name = network;
    dns = [ "10.10.10.3" ];
    matchConfig.Name = network;
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
}
