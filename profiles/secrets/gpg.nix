{ pkgs, lib, ... }:

let
  inherit (lib) mkIf mkMerge mkSinkUndeclaredOptions optionalAttrs;
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
in
{
  # options.services.dbus = mkIf isDarwin (mkSinkUndeclaredOptions { });

  config = mkMerge [
    (mkIf isLinux {
      # Pinentry configuration for gpg-agent with pinentry-gnome3
      services.dbus.packages = [ pkgs.gcr ];
      my.home = {
        # gnome3 pinentry unbroken in my Sway setup with
        # dbus-update-activation-environment from 'on-startup-shutdown' script
        home.file.".gnupg/gpg-agent.conf".text = ''
          pinentry-program ${pkgs.pinentry.gnome3}/bin/pinentry
          # pinentry-program ${pkgs.pinentry.qt}/bin/pinentry
        '';
        services.gpg-agent.pinentryFlavor = "gnome3";
        # services.gpg-agent.pinentryFlavor = "qt";
      };
    })
    (mkIf isDarwin {
      # pinentry-mac is not packaged on nixpkgs
      my.home.home.file.".gnupg/gpg-agent.conf".text = ''
        pinentry-program /usr/local/bin/pinentry-mac
      '';
    })
    {
      my.home = { config, ... }: {
        services.gpg-agent = {
          enable = false;
          enableSshSupport = false;
        };

        programs.gpg = {
          enable = true;
          settings = let
            inherit (config.my.identity) gpgSigningKey;
            hasGpgSigningKey = gpgSigningKey != null;
          in {
            use-agent = false;
            default-key = mkIf hasGpgSigningKey "0x${gpgSigningKey}";
            trusted-key = mkIf hasGpgSigningKey "0x${gpgSigningKey}";
          };
        };
      };
    } #
  ];
}
