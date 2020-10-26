{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.targetPlatform) isDarwin isLinux;

  inherit (config.my) username;
in
lib.mkMerge [
  (lib.mkIf isLinux {
    users.users.${username} = {
      createHome = true;
      isNormalUser = true;
      shell = pkgs.zsh;
      uid = 1000;
      group = username;
      home = "/home/${username}";
      extraGroups = [ "wheel" "networkmanager" "input" "audio" "video" "dialout" ]
        ++ (lib.optional config.virtualisation.docker.enable "docker");
    };
    users.groups.${username} = { };

    my.home = { pkgs, ... }: {
      gtk = {
        enable = true;
        iconTheme = {
          name = "Adwaita";
          # Covered by the theme package below
          # package = pkgs.gnome3.gnome-themes-extra;
        };
        theme = {
          name = "Adwaita";
          package = pkgs.gnome3.gnome-themes-extra;
        };
        gtk2.extraConfig = ''
          gtk-cursor-theme-name="Adwaita"
          gtk-cursor-theme-size="24"
        '';
        gtk3.extraConfig = {
          "gtk-cursor-theme-name" = "Adwaita";
          "gtk-cursor-theme-size" = 24;
        };
      };
      xsession.pointerCursor = {
        package = pkgs.gnome3.gnome-themes-extra;
        name = "Adwaita";
        size = 24;
      };
      xsession.preferStatusNotifierItems = true;

      qt = {
        enable = true;
        platformTheme = "gnome";
      };

      # Passwords and stuff
      services.gnome-keyring.enable = true;

      # services.lorri.enable = true;
      services.blueman-applet.enable = true;
      services.kdeconnect.enable = true;
      services.kdeconnect.indicator = true;
      # Started with libindicator if `xsession.preferStatusNotifierItems = true`
      services.network-manager-applet.enable = true;

      # Run emacs as a service
      services.emacs.enable = true;
      # Makes the desktop file `exec = emacsclient`
      services.emacs.client.enable = true;
    };
  })
  # </isLinux>

  {
    my.home = { ... }: {
      my.identity = {
        name = "Nicolas Berbiche";
        email = "nic.berbiche" + "@gmail.com";
        gpgSigningKey = "B461292445C6E696";
      };

      home.sessionVariables = {
        NIX_PAGER = "less --RAW-CONTROL-CHARS --quit-if-one-screen";
      };

      # HomeManager config
      # `man 5 home-configuration.nix`
      manual.manpages.enable = true;

      # XDG
      fonts.fontconfig.enable = lib.mkForce true;
      programs.emacs.enable = true;
    };
  }
]
