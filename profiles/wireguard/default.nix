{ config, pkgs, ... }:

{
  imports = [ ./tq-rs.nix ];

  systemd.network.enable = true;

  system.activationScripts.configure-wireguard-permissions = ''
    mkdir -p /private/wireguard
    echo "Setting Wireguard folder permissions"
    chmod -c 0755 /private /private/wireguard
    chmod -c 0440 /private/wireguard/*
    chown -cR root:systemd-network /private/wireguard
  '';
}
