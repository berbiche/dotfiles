{ config, lib, rootPath, ... }:

{
  sops.secrets.nix-config = {
    sopsFile = rootPath + "/secrets/nix-config.cfg";
    mode = "0400";
    format = "binary";
    path = "${config.xdg.configHome}/nix/01-managed-by-home-manager.cfg";
  };

  nix.extraOptions = lib.mkAfter ''
    !include ${config.sops.secrets.nix-config.path}
  '';
}
