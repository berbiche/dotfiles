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
        # Pinentry gnome3 is broken on 2021-02-02
        #services.gpg-agent.pinentryFlavor = "gnome3";
        services.gpg-agent.pinentryFlavor = "qt";
      };
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
            default-key = lib.mkIf hasGpgSigningKey "0x${gpgSigningKey}";
            trusted-key = lib.mkIf hasGpgSigningKey "0x${gpgSigningKey}";
          };
        };
      };
    } #
  ];
}
