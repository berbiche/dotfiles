{ config, pkgs, ... }:

{
  imports = [
    ./tq-rs.nix
    ./smb.nix
  ];

  systemd.network.enable = true;

  system.activationScripts.configure-wireguard-permissions = ''
    mkdir -p /private/wireguard
    echo "setting Wireguard folder permissions"
    chmod -c 0755 /private /private/wireguard || true
    find /private/wireguard -type f -exec chmod -c 0440 {} +
    chown -cR root:systemd-network /private/wireguard || true
  '';
}
