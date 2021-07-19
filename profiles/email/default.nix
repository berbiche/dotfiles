{ config, lib, pkgs, ... }:

with lib;

let
  topConf = config;
  poorObsfucation = y: x: "${x}@${y}";
  passCmd = x: "${pkgs.libsecret}/bin/secret-tool lookup account ${x}";
in
{
  imports = [ ./neomutt.nix ];

  my.home = { config, lib, ... }: let
    mbsyncCmd = "${config.programs.mbsync.package}/bin/mbsync";
  in {
    accounts.email.maildirBasePath = "${config.home.homeDirectory}/mail";

    accounts.email.accounts.gmail = let
      emailCfg = config.accounts.email.accounts.gmail;
    in rec {
      primary = true;
      maildir.path = "gmail";

      flavor = "gmail.com";

      address = poorObsfucation "gmail.com" "nic.berbiche";
      realName = config.my.identity.name;
      userName = address;
      passwordCommand = passCmd "gmail";

      # himalaya.enable = true;
      himalaya.settings = {
        downloads-dir = "${emailCfg.maildir.absPath}/attachments";
      };

      # Enable sending messages
      msmtp.enable = true;

      # Alternative to Himalaya that supports local maildir
      # Himalaya requires a dovecot/mailserver installation to use "offline/local" storage
      neomutt.enable = true;
      neomutt.extraConfig = ''
        set sort = "reverse-threads";
      '';
      # Tag email
      notmuch.enable = true;

      # Spawns an idle connection to receive email push events
      imapnotify = {
        enable = true;
        boxes = [ "Inbox" ];
        onNotify = pkgs.writeShellScript "imap-on-notify" ''
          ${mbsyncCmd} gmail
          NOTMUCH_CONFIG=${escapeShellArg config.home.sessionVariables.NOTMUCH_CONFIG}
          NMBGIT=${escapeShellArg config.home.sessionVariables.NMBGIT}
          ${pkgs.notmuch}/bin/notmuch new
        '';
        onNotifyPost = pkgs.writeShellScript "imap-on-notify-post" ''
          ${pkgs.notify-send_sh}/bin/notify-send.sh --icon=mail-unread --app-name=imapnotify \
            "Email" "New email available in Inbox"
        '';
      };

      # Synchronizes emails to a local directory
      mbsync = {
        enable = true;
        # The following options do not work when using channels...
        create = "maildir";
        remove = "none";
        expunge = "both";

        extraConfig.account.SSLType = "IMAPS";
        extraConfig.account.SSLVersions = "TLSv1.2";

        groups.gmail.channels = mapAttrs (_: v: v // {
          extraConfig.Create = "Near";
          extraConfig.MaxMessages = 1000000;
          extraConfig.MaxSize = "10m";
          extraConfig.Sync = "All";
          extraConfig.SyncState = "*";
        }) {
          inbox.farPattern = "";
          inbox.nearPattern = "";
          inbox.extraConfig.Expunge = "Both";
          archive.farPattern = "[Gmail]/All Mail";
          archive.nearPattern = "archive";
          sent.farPattern = "[Gmail]/Sent Mail";
          sent.nearPattern = "Sent";
          sent.extraConfig.Expunge = "Both";
          trash.farPattern = "[Gmail]/Bin";
          trash.nearPattern = "Trash";
          starred.farPattern = "[Gmail]/Starred";
          starred.nearPattern = "Starred";
          drafts.farPattern = "[Gmail]/Drafts";
          drafts.nearPattern = "Drafts";
          drafts.extraConfig.Expunge = "Both";
        };
      };
    };

    # Play the msn alert sound when receiving a notification
    services.dunst.settings.incoming-mail = {
      summary = "Email";
      body = "New email*";
      script = let
        # The sound file will have to be synchronized manually because I don't think
        # I can include it in this repository due to copyrights?
        sound = ''"$(${pkgs.xdg-user-dirs}/bin/xdg-user-dir MUSIC)/msn_alert.wav"'';
      in toString (pkgs.writeShellScript "dunst-email" ''
        test -f ${sound} || exit
        ${lib.optionalString topConf.services.pipewire.enable ''
          ${pkgs.pipewire}/bin/pw-play --volume 0.8 ${sound}
        ''}
        ${lib.optionalString topConf.hardware.pulseaudio.enable ''
          ${pkgs.pulseaudio}/bin/paplay --volume 30000 ${sound}
        ''}
      '');
    };

    # Local maildir
    programs.mbsync.enable = true;

    # To send emails
    programs.msmtp.enable = true;

    # Mail indexer and tagger
    programs.notmuch.enable = true;

    # Notifies mbsync of new emails
    services.imapnotify.enable = true;

    # Sync emails on initial login
    systemd.user.services.mbsync-oneshot = {
      Unit = {
        Description = "mbsync oneshot synchronisation";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${mbsyncCmd} --all";
        RemainAfterExit = true;
      };
      Install.WantedBy = [ "default.target" ];
    };

    home.file.".mailcap".text = ''
    '';
  };
}
