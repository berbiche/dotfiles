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
  programs.ssh.hashKnownHosts = true;
  programs.ssh.extraConfig = ''
      IdentitiesOnly yes
      IgnoreUnknown UseKeychain
      UseKeychain yes
  '';

  # Fuck it, let's just hardcode the public key :-)
  home.file.".ssh/yubikey.pub".text = ''
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6jrY1lhogYVDj73Nzr0aXROokQ2MxsgFzqrLIfO/VffBE78GdAOs2MiYD/EYPoG5azxblujH1Nd18ohShuW6GHGsHaX8/i6lg92Ukxp8aAzdiSZSoJz6UjY9JIAquMHx4wQLuVj7TzaQ6r3UFFCzQT3zVoD1xOo1Ajww5WCUp7sYu80htEPbDoPVfjWv7PJAIibVZatV8S6mlsXoIYDoTXD2uxMe6rlWsTeYWyIocg5SBqc0dsvkOx+ga1XcKHOBSjH31osQO7FRz7jhUC69IPr++ZSfHitG25CEVyhkStF5ZZ1cuo5I0gLTgaWXreF0kjcnUtqF0KViRfeBDB9Rbhv/k816WkVLBNEsy/Bw9Ly2eDYLmdBmdp91AropRvOaMDHtjBxn3Z+4WcA+PL9rcGtwPBwFHTD3RUJcpOmo8aR58xm7usLrwIn7Ulg+kEqTll+fuhpOmyCjC6K8/uPdRconJG+eGPMpYl5Oezz0a6gX7onugw9iQkMc9cTom2RmXLrGkPEPT1ARRRxsgYqFycoyuVP2vF19HzqI1y26CTf/zKrt9q2G95NVP1Pcx1yHlpfqwnWktih+iND5INrffXiKiFWVXTrkPZY99mcM1tkQ80cDff5q4xtQLDC/yO8iVSp1mY7T+J4tpA6FrCUk2FTT5yVIf6o1d4oJPwZxr4Q==
  '';
}
