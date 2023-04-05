{ config, lib, pkgs, ... }@args:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin isAarch64;
  osConfig = args.osConfig or { };
in
lib.mkMerge [
  {
    # home.file.".gnupg/gpg-agent.conf".text = lib.mkAfter ''
    #   pinentry-program ${pkgs.pinentry.gnome3}/bin/pinentry
    #   # pinentry-program ${pkgs.pinentry.qt}/bin/pinentry
    # '';
    services.gpg-agent = lib.mkIf isLinux {
      pinentryFlavor = "gnome3";
      enable = true;
      enableSshSupport = true;
    };

    programs.gpg = {
      enable = true;
      settings = let
        inherit (config.my.identity) gpgSigningKey;
        hasGpgSigningKey = gpgSigningKey != null;
      in {
        default-key = lib.mkIf hasGpgSigningKey "0x${gpgSigningKey}";
        trusted-key = lib.mkIf hasGpgSigningKey "0x${gpgSigningKey}";
      };
    };
  }

  (lib.mkIf isDarwin {
    # pinentry-mac is not packaged on nixpkgs
    home.file.".gnupg/gpg-agent.conf".text =  lib.mkAfter ''
      pinentry-program ${
        if isAarch64 then
          "${osConfig.homebrew.brewPrefix or "/opt/homebrew/bin"}/pinentry-mac"
        else
          "/usr/local/bin/pinentry-mac"
      }
    '';

    programs.gpg.scdaemonSettings = {
      disable-ccid = true;
    };
  })
]
