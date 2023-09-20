{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in
{
  programs.zsh.enable = true;
  programs.bash.enable = true;
  programs.fish.enable = true;
  home.shellAliases = rec {
    ".."      = "cd ..";
    "..."     = "cd ../..";
    "...."    = "cd ../../..";
    "....."   = "cd ../../../..";
    e         = "$EDITOR";
    ls        = "${pkgs.eza}/bin/exa --color=auto --group-directories-first --classify";
    lst       = "${ls} --tree";
    la        = "${ls} --all";
    ll        = "${ls} --all --long --header --group";
    llt       = "${ll} --tree";
    tree      = "${ls} --tree";
    batnp     = "${pkgs.bat}/bin/bat --pager=''";
    cat       = "cat -v";
    cdtemp    = ''cd "$(mktemp -d)"'';
    cp        = "cp -iv";
    ln        = "ln -v";
    mkdir     = "mkdir -vp";
    mv        = "mv -iv";
    rm        = if isDarwin then "rm -v" else "rm --one-file-system -Iv";
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
    trash     = lib.mkIf isLinux "GTK_USE_PORTAL=0 gio trash";
  };
}
