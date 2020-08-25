{ pkgs, stdenv, ... }:

{
  home.packages = [ pkgs.gnupg ];

  services.gpg-agent = {
    enable = false;
    enableSshSupport = false;
  };

  home.file."gnupg" = {
    target = ".gnupg/gpg.conf";
    text = ''
      digest-algo SHA256
      personal-digest-preferences SHA512,SHA384,SHA256,SHA224
      default-preference-list SHA512,SHA384,SHA256,SHA224,AES256,AES192,AES,CAST5,3DES,BZIP2,ZIP,ZLIB,Uncompressed
    '';
  };
  home.file."gnupg-agent" = lib.mkIf stdenv.isLinux {
    target = ".gnupg/gpg-agent.conf";
    text = ''
      # Hacky gnome-keyring configuration
      pinentry-program ${pkgs.pinentry-gtk2}/bin/pinentry
    '';
  };
}
