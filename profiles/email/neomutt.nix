{ config, lib, ... }:

with lib;

{
  my.home = { config, ... }: {
    # MUA
    programs.neomutt.enable = true;
    programs.neomutt.sidebar.enable = true;
    # programs.neomutt.vimKeys = true;

    programs.neomutt.sort = "reverse-threads";

    # Taken from mutt-wizard/mutt-wizard.muttrc
    programs.neomutt.settings = {
      date_format = ''"%y/%m/%d %I:%M%p"'';
      index_format = ''"%2C %Z %?X?A& ? %D %-15.15F %s (%-4.4c)"'';
      query_command = ''"abook --mutt-query '%s'"'';
      rfc2047_parameters = "yes";
      # Pause 0 seconds for informational messages
      sleep_time = "0";
      # Disables the `+` displayed at line wraps
      markers = "no";
      # Unread mail stay unread until read;
      mark_old = "no";
      # attachments are forwarded with mail;
      mime_forward = "yes";
      # mutt won't ask "press key to continue";
      wait_key = "no";
      # skip to compose when replying
      fast_reply = "yes";
      # save attachments with the body
      fcc_attach = "yes";
      # format of subject when forwarding;
      forward_format = ''"Fwd: %s"'';
      # include message in forwards
      forward_quote = "yes";
      # reply as whomever it was to
      reverse_name = "yes";
      # include message in replies
      include = "yes";
    };

    # Taken from mutt-wizard/mutt-wizard.muttrc
    programs.neomutt.binds = map (x: let
      x' = splitString " " x;
    in {
      map = splitString "," (head x');
      key = elemAt x' 1;
      action = last x';
    }) [
      "index,pager i noop"
      "index,pager g noop"
      "index \\Cf noop"
      "index j next-entry"
      "index k previous-entry"
      "attach <return> view-mailcap"
      "attach l view-mailcap"
      "editor <space> noop"
      "index G last-entry"
      "index gg first-entry"
      "pager,attach h exit"
      "pager j next-line"
      "pager k previous-line"
      "pager l view-attachments"
      "index D delete-message"
      "index U undelete-message"
      "index L limit"
      "index h noop"
      "index l display-message"
      "index,query <space> tag-entry"
      "browser h goto-parent"
      "index,pager H view-raw-message"
      "browser l select-entry"
      "pager,browser gg top-page"
      "pager,browser G bottom-page"
      "index,pager,browser d half-down"
      "index,pager,browser u half-up"
      "index,pager S sync-mailbox"
      "index,pager R group-reply"
      "index \\031 previous-undeleted"	# Mouse wheel
      "index \\005 next-undeleted"		  # Mouse wheel
      "pager \\031 previous-line"		    # Mouse wheel
      "pager \\005 next-line"		        # Mouse wheel
      "editor <Tab> complete-query"

      # Pager stuff
      "index,pager \\Ck sidebar-prev"
      "index,pager \\Cj sidebar-next"
      "index,pager \\Co sidebar-open"
      "index,pager \\Cp sidebar-prev-new"
      "index,pager \\Cn sidebar-next-new"

      "index,pager B sidebar-toggle-visible"
    ];

    # Taken from mutt-wizard/mutt-wizard.muttrc
    programs.neomutt.extraConfig = ''
      # Default index colors:
      color index yellow default '.*'
      color index_author red default '.*'
      color index_number blue default
      color index_subject cyan default '.*'

      # New mail is boldened:
      color index brightyellow black "~N"
      color index_author brightred black "~N"
      color index_subject brightcyan black "~N"


      # Tagged mail is highlighted:
      color index brightyellow blue "~T"
      color index_author brightred blue "~T"
      color index_subject brightcyan blue "~T"


      # Other colors and aesthetic settings:
      mono bold bold
      mono underline underline
      mono indicator reverse
      mono error bold
      color normal default default
      color indicator brightblack white
      color sidebar_highlight red default
      color sidebar_divider brightblack black
      color sidebar_flagged red black
      color sidebar_new green black
      color normal brightyellow default
      color error red default
      color tilde black default
      color message cyan default
      color markers red white
      color attachment white default
      color search brightmagenta default
      color status brightyellow black
      color hdrdefault brightgreen default
      color quoted green default
      color quoted1 blue default
      color quoted2 cyan default
      color quoted3 yellow default
      color quoted4 red default
      color quoted5 brightred default
      color signature brightgreen default
      color bold black default
      color underline black default
      color normal default default


      # Regex highlighting:
      color header blue default ".*"
      color header brightmagenta default "^(From)"
      color header brightcyan default "^(Subject)"
      color header brightwhite default "^(CC|BCC)"
      color body brightred default "[\-\.+_a-zA-Z0-9]+@[\-\.a-zA-Z0-9]+" # Email addresses
      color body brightblue default "(https?|ftp)://[\-\.,/%~_:?&=\#a-zA-Z0-9]+" # URL
      color body green default "\`[^\`]*\`" # Green text between ` and `
      color body brightblue default "^# \.*" # Headings as bold blue
      color body brightcyan default "^## \.*" # Subheadings as bold cyan
      color body brightgreen default "^### \.*" # Subsubheadings as bold green
      color body yellow default "^(\t| )*(-|\\*) \.*" # List items as yellow
      color body brightcyan default "[;:][-o][)/(|]" # emoticons
      color body brightcyan default "[;:][)(|]" # emoticons
      color body brightcyan default "[ ][*][^*]*[*][ ]?" # more emoticon?
      color body brightcyan default "[ ]?[*][^*]*[*][ ]" # more emoticon?
      color body red default "(BAD signature)"
      color body cyan default "(Good signature)"
      color body brightblack default "^gpg: Good signature .*"
      color body brightyellow default "^gpg: "
      color body brightyellow red "^gpg: BAD signature from.*"
      mono body bold "^gpg: Good signature"
      mono body bold "^gpg: BAD signature from.*"
      color body red default "([a-z][a-z0-9+-]*://(((([a-z0-9_.!~*'();:&=+$,-]|%[0-9a-f][0-9a-f])*@)?((([a-z0-9]([a-z0-9-]*[a-z0-9])?)\\.)*([a-z]([a-z0-9-]*[a-z0-9])?)\\.?|[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+)(:[0-9]+)?)|([a-z0-9_.!~*'()$,;:@&=+-]|%[0-9a-f][0-9a-f])+)(/([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*(;([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*)*(/([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*(;([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*)*)*)?(\\?([a-z0-9_.!~*'();/?:@&=+$,-]|%[0-9a-f][0-9a-f])*)?(#([a-z0-9_.!~*'();/?:@&=+$,-]|%[0-9a-f][0-9a-f])*)?|(www|ftp)\\.(([a-z0-9]([a-z0-9-]*[a-z0-9])?)\\.)*([a-z]([a-z0-9-]*[a-z0-9])?)\\.?(:[0-9]+)?(/([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*(;([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*)*(/([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*(;([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*)*)*)?(\\?([-a-z0-9_.!~*'();/?:@&=+$,]|%[0-9a-f][0-9a-f])*)?(#([-a-z0-9_.!~*'();/?:@&=+$,]|%[0-9a-f][0-9a-f])*)?)[^].,:;!)? \t\r\n<>\"]"
    '';
  };
}
