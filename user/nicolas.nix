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
      ++ (lib.optional config.virtualisation.docker.enable "docker")
      ++ (lib.optional config.virtualisation.libvirtd.enable "libvirtd")
      ;
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
      # Disabled: https://github.com/nix-community/home-manager/issues/1454
      services.gnome-keyring.enable = true;
      services.gnome-keyring.components = [ "secrets" "ssh" ];

      services.blueman-applet.enable = true;
      # Started with libindicator if `xsession.preferStatusNotifierItems = true`
      services.network-manager-applet.enable = true;
    };
  })
  # </isLinux>

  {
    my.home = { ... }: {
      my.identity.gpgSigningKey = "1D0261F6BCA46C6E";
      my.identity = {
        name = "Nicolas Berbiche";
        email = "nic.berbiche" + "@gmail.com";
      };

      # HomeManager config
      # `man 5 home-configuration.nix`
      manual.manpages.enable = true;

      # XDG
      fonts.fontconfig.enable = lib.mkForce true;
    };
  }
]
