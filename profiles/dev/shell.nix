{ ... }:

{
  my.home = { config, lib, pkgs, ... }: {
    home.shellAliases = {
      ".."      = "cd ..";
      "..."     = "cd ../..";
      "...."    = "cd ../../..";
      "....."   = "cd ../../../..";
      ls        = "${pkgs.exa}/bin/exa --color=auto --group-directories-first --classify";
      lst       = "${ls} --tree";
      la        = "${ls} --all";
      ll        = "${ls} --all --long --header --group";
      llt       = "${ll} --tree";
      tree      = "${ls} --tree";
      batnp     = "${pkgs.bat}/bin/bat --pager=''";
      cdtemp    = "cd `mktemp -d`";
      cp        = "cp -iv";
      ln        = "ln -v";
      mkdir     = "mkdir -vp";
      mv        = "mv -iv";
      rm        = if isDarwin then "rm -v" else "rm -Iv";
      dh        = "du -h";
      df        = "df -h";
      py        = "ptipython";
      # su        = "sudo -E su -m";
      systemctl = "command systemctl --no-pager --full";
      sysu      = "${systemctl} --user";
      jnsu      = "journalctl --user";
      svim      = "sudoedit";
      # The GTK portal to trash files does not work on Sway :(
      # with xdg-desktop-portal-gtk
      trash     = mkIf isLinux "GTK_USE_PORTAL=0 gio trash";
    };
  };
}
