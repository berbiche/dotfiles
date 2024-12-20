{ config, lib, pkgs, ... }@args:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin isAarch64;
  osConfig = args.osConfig or { };

  sopsKeyFile = "${config.xdg.configHome}/sops/age/keys.txt";
in
{
  imports = [ ./ssh.nix ./nix-conf.nix ];

  config = lib.mkMerge [
    {
      home.packages = [ pkgs.age pkgs.sops ];
    }
    {

      # Create folder, I don't care if the folder is 755, as long as the content
      # of the secrets themselves is 400
      xdg.configFile."sops/age/.keep".text = "Managed by Home Manager.";
      sops.age.keyFile = sopsKeyFile;
      sops.age.generateKey = false;
      home.sessionVariables.SOPS_AGE_KEY_FILE = sopsKeyFile;

      home.activation.setupSops = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        __systemctl() {
          if [ -x /run/current-system/sw/bin/systemctl ]; then
            echo /run/current-system/sw/bin/systemctl
          elif [ -x /usr/bin/systemctl ]; then
            echo /usr/bin/systemctl
          fi
        }
        systemctl=$(__systemctl)

        if [ -n "$systemctl" ]; then
          if "$systemctl" --quiet --user list-unit-files sops-nix; then
            "$systemctl" start --user sops-nix
          fi
        fi
      '';

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
            "${osConfig.homebrew.brewPrefix}/pinentry-mac"
          else
            "/usr/local/bin/pinentry-mac"
        }
      '';

      programs.gpg.scdaemonSettings = {
        disable-ccid = true;
      };
    })
  ];
}
