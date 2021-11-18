{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.smb;
in
{
  options.profiles.smb = {
    enable = lib.mkEnableOption "SMB public-share truenas mount";

    secretFile = lib.mkOption {
      type = lib.types.either lib.types.path lib.types.str;
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = config.my.username;
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = config.users.users.${cfg.user}.group;
    };
  };

  config = lib.mkIf cfg.enable {
    /*
      Setup:
      1. sudo nix run nixpkgs#ssh-to-pgp -- -i /etc/ssh/ssh_host_rsa_key -o secrets/hosts/"$(hostname -s)".asc
      2. Copy the fingerprint to `.sops.yaml`
    */
    sops.secrets.smb-public-share = {
      sopsFile = cfg.secretFile;
      mode = "0400";
      format = "binary";
    };

    systemd.tmpfiles.rules = [
      #Type Path              Mode User        Group        Age Argument
      "d    /mnt/public-share 0770 ${cfg.user} ${cfg.group} -   -"
    ];

    fileSystems."/mnt/public-share" = {
      device = "//truenas.node.tq.rs/public-share";
      fsType = "cifs";
      options = [
        "noauto" # "noatime" "nodiratime"
        "x-systemd.automount" "x-systemd.idle-timeout=60" "x-systemd.device-timeout=5s"
        "x-systemd.mount-timeout=5s"
        "iocharset=utf8" "workgroup=WORKGROUP"
        "uid=${toString config.users.users.${cfg.user}.uid}" "gid=${toString config.users.groups.${cfg.group}.gid}"
        "credentials=${config.sops.secrets.smb-public-share.path}"
        "vers=3.1.1"
      ];
    };
  };
}
