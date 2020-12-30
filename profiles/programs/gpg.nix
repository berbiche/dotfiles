{ pkgs, lib, ... }:

let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkIf mkMerge;
in
mkMerge [
  (mkIf isLinux {
    # Pinentry configuration for gpg-agent with pinentry-gnome3
    services.dbus.packages = [ pkgs.gcr ];
    my.home = {
      home.file.".gnupg/gpg-agent.conf".text = ''
        pinentry-program ${pkgs.pinentry.gnome3}/bin/pinentry
      '';
      services.gpg-agent.pinentryFlavor = "gnome3";
    };
  })
  {
    my.home = {
      home.packages = [ pkgs.gnupg ];

      services.gpg-agent = {
        enable = false;
        enableSshSupport = false;
      };

      home.file."gnupg" = {
        target = ".gnupg/gpg.conf";
        text = ''
          digest-algo SHA256
          personal-digest-preferences SHA512,SHA384,SHA256,SHA224
          default-preference-list SHA512,SHA384,SHA256,SHA224,AES256,AES192,AES,CAST5,3DES,BZIP2,ZIP,ZLIB,Uncompressed
        '';
      };
    };
  }
]
