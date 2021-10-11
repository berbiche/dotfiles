{ config, lib, pkgs, ... }:

with lib;

let
  topConf = config;
  poorObsfucation = y: x: "${x}@${y}";
  passCmd = x: "${pkgs.libsecret}/bin/secret-tool lookup account ${x}";
in
{
  my.home = { config, ... }: let
    mbsyncCmd = "${config.programs.mbsync.package}/bin/mbsync";
  in {
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
      neomutt.mailboxName = "gmail.com";
      neomutt.extraMailboxes = [
        "archive" "Drafts" "Sent" "Starred" "Trash"
      ];
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

    accounts.email.accounts."normie.dev" = let
      emailCfg = config.accounts.email.accounts."normie.dev";
    in rec {
      primary = false;
      maildir.path = "normie.dev";

      imap = {
        host = "mail.normie.dev";
        port = 993;
        tls.enable = true;
      };
      smtp = {
        host = "mail.normie.dev";
        port = 587;
        tls.enable = true;
      };

      flavor = "plain";

      address = poorObsfucation "normie.dev" "nicolas";
      realName = config.my.identity.name;
      userName = address;
      passwordCommand = passCmd "normie.dev";

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
      neomutt.mailboxName = "normie.dev";
      neomutt.extraMailboxes = [
        "Drafts" "Sent" "Trash" "Junk"
      ];
      # Tag email
      notmuch.enable = true;

      # Spawns an idle connection to receive email push events
      imapnotify = {
        enable = true;
        boxes = [ "Inbox" ];
        onNotify = pkgs.writeShellScript "imap-on-notify" ''
          ${mbsyncCmd} normie.dev
          NOTMUCH_CONFIG=${escapeShellArg config.home.sessionVariables.NOTMUCH_CONFIG}
          NMBGIT=${escapeShellArg config.home.sessionVariables.NMBGIT}
          ${pkgs.notmuch}/bin/notmuch new
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
          sent.farPattern = "Sent";
          sent.nearPattern = "Sent";
          sent.extraConfig.Expunge = "Both";
          trash.farPattern = "Trash";
          trash.nearPattern = "Trash";
          drafts.farPattern = "Drafts";
          drafts.nearPattern = "Drafts";
          drafts.extraConfig.Expunge = "Both";
          junk.farPattern = "Junk";
          junk.nearPattern = "Junk";
          junk.extraConfig.Expunge = "Both";
        };
      };
    };

  };
}
