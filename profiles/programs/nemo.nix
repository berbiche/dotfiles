{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.targetPlatform) isDarwin isLinux;
in
lib.mkIf isLinux {
  home.packages = [ pkgs.gnome.file-roller ];

  xdg.dataFile."nemo/actions/extract-here.nemo_action".text = ''
    [Nemo Action]
    Active=true
    Name=Extract here
    Comment=Extract here
    Exec=${pkgs.gnome.file-roller}/bin/file-roller --extract-here %F
    Icon-Name=gnome-mime-application-x-compress
    Selection=Any
    Extensions=zip;7z;ar;cbz;cpi;exe;iso;jar;tar;tar.z;tar.bz2;tar.gz;tar.lz;tar.lzma;tar.xz
    Quote=double
  '';

  xdg.dataFile."nemo/actions/extract-to.nemo_action".text = ''
    [Nemo Action]
    Active=true
    Name=Extract to ...
    Comment=Extract to ...
    Exec=${pkgs.gnome.file-roller}/bin/file-roller --extract %F
    Icon-Name=gnome-mime-application-x-compress
    Selection=Any
    Extensions=zip;7z;ar;cbz;cpi;exe;iso;jar;tar;tar.z;tar.bz2;tar.gz;tar.lz;tar.lzma;tar.xz
    Quote=double
  '';

  xdg.dataFile."nemo/actions/compress.nemo_action".text = ''
    [Nemo Action]
    Active=true
    Name=Compress
    Comment=Compress %N
    Exec=${pkgs.gnome.file-roller}/bin/file-roller --notify --default-dir=%P --add %F
    Icon-Name=gnome-mime-application-x-compress
    Selection=Any
    Extensions=any;
    Quote=double
  '';
}
