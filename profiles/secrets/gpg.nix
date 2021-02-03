{ pkgs, lib, ... }:

let
  inherit (pkgs.stdenv) isLinux isDarwin;
  inherit (lib) mkIf mkMerge;
in
{
  options.services.dbus = lib.optionalAttrs isDarwin (lib.mkSinkUndeclaredOptions { });

  config = mkMerge [
    (mkIf isLinux {
      # Pinentry configuration for gpg-agent with pinentry-gnome3
      services.dbus.packages = [ pkgs.gcr ];
      my.home = {
        home.file.".gnupg/gpg-agent.conf".text = ''
          # pinentry-program ${pkgs.pinentry.gnome3}/bin/pinentry
          pinentry-program ${pkgs.pinentry.qt}/bin/pinentry
        '';
        # Pinentry gnome3 is broken on latest version
        #services.gpg-agent.pinentryFlavor = "gnome3";
        services.gpg-agent.pinentryFlavor = "qt";
      };
    })
    {
      my.home = { config, ... }: {
        home.packages = [ pkgs.gnupg ];

        services.gpg-agent = {
          enable = false;
          enableSshSupport = false;
        };

        home.file."gnupg" = {
          target = ".gnupg/gpg.conf";
          text = ''
            # Enable smartcard
            #use-agent

            # Default signing key
            ${lib.optionalString (config.my.identity.gpgSigningKey != null) ''
              default-key 0x${config.my.identity.gpgSigningKey}
              trusted-key 0x${config.my.identity.gpgSigningKey}
            ''}

            digest-algo SHA256
            personal-digest-preferences SHA512,SHA384,SHA256,SHA224
            default-preference-list SHA512,SHA384,SHA256,SHA224,AES256,AES192,AES,CAST5,3DES,BZIP2,ZIP,ZLIB,Uncompressed

            # Show Unix timestamps
            fixed-list-mode
            #Long hexadecimal key format
            keyid-format 0xlong
          '';
        };
      };
    }
  ];
}
