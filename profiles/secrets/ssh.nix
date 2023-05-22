{ config, lib, pkgs, rootPath, ... }:

{
  sops.secrets.ssh-config = {
    sopsFile = rootPath + "/secrets/ssh-config.cfg";
    mode = "0400";
    format = "binary";
    path = "${config.home.homeDirectory}/.ssh/config.d/01-managed-by-home-manager.cfg";
  };

  home.file.".ssh/config.d/.keep".text = "# Managed by Home Manager";

  programs.ssh.enable = true;

  programs.ssh.includes = [
    "config.d/*.cfg"
  ];
  programs.ssh.matchBlocks."git-hosts" = {
    host = "github.com gitlab.com";
    identityFile = [
      "~/.ssh/yubikey.pub"
      "~/.ssh/github.pub"
    ];
  };
  programs.ssh.extraConfig = ''
      IdentitiesOnly yes
      IgnoreUnknown UseKeychain
      UseKeychain yes
  '';
}
