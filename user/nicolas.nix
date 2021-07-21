{ config, lib, pkgs, isLinux, isDarwin, ... }:

let
  inherit (config.my) username;
in
lib.mkMerge [
  (lib.optionalAttrs isLinux {
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
      initialPassword = username;
    };
    users.groups.${username} = { };

    my.home = { config, pkgs, ... }: {
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
        style = {
          name = "Adwaita";
          # package = config.gtk.theme.package;
          package = pkgs.adwaita-qt;
        };
      };

      xdg.userDirs = {
        enable = true;
        extraConfig = {
          "XDG_SCREENSHOTS_DIR" = "${config.xdg.userDirs.pictures}/screenshots";
        };
      };

      # Passwords and stuff
      # Disabled: https://github.com/nix-community/home-manager/issues/1454
      services.gnome-keyring.enable = true;
      services.gnome-keyring.components = [ "secrets" "ssh" ];

      services.blueman-applet.enable = true;
      systemd.user.services.blueman-applet = {
        Unit.After = lib.mkForce [ "graphical-session.target" ];
      };
      # Started with libindicator if `xsession.preferStatusNotifierItems = true`
      services.network-manager-applet.enable = true;
      systemd.user.services.network-manager-applet = {
        Unit.After = lib.mkForce [ "graphical-session.target" ];
      };

      # Playerctl smart daemon to stop the "last player"
      # supposedly smarter than the default play-pause behavior
      services.playerctld.enable = true;

      home.packages = [
        # Force Zoom to run on X11 for all the popups and everything
        (pkgs.zoom-us.overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs or [] ++ [ pkgs.makeWrapper ];
          postFixup = old.postFixup or "" + ''
            wrapProgram $out/bin/zoom --set QT_QPA_PLATFORM xcb
          '';
        }))
        pkgs.discord
        pkgs.teams
      ];

      # Copy the scripts folder
      home.file."scripts".source = let
        path = lib.makeBinPath (with pkgs; [
          gawk gnused jq wget
          pulseaudio # for pactl
          pamixer # volume control
          volnoti # show a popup notification for the volume level
          sway # for swaymsg
          wl-clipboard # wl-copy/wl-paste
          fzf # menu
          wofi # menu
          xdg-user-dirs # for the screenshot tool
          networkmanager # for nmcli
          notify-send_sh # from my overlays
          playerctl # to control mpris players
          util-linux # flock
          my-nur.eww-wayland # 'eww open'
        ]);
      in "${
        # For the patchShebang phase
        pkgs.runCommandLocal "sway-scripts" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
          cp --no-preserve=mode -T -r "${./scripts}" $out
          chmod +x $out/*
          for i in $out/*; do
            wrapProgram $i --prefix PATH : ${path}
          done
        ''
      }";
    };
  })
  # </isLinux>

  {
    my.home = { ... }: {
      my.identity = {
        name = "Nicolas Berbiche";
        email = "nicolas@normie.dev";
        # My GPG signing key
        gpgSigningKey = "1D0261F6BCA46C6E";
      };

      # HomeManager config
      # `man 5 home-configuration.nix`
      manual.manpages.enable = true;

      # XDG
      fonts.fontconfig.enable = lib.mkForce true;
    };
  }
]
