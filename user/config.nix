{ pkgs, ... }:

{
  allowUnfree = true;
  permittedInsecurePackages = [
    "openssl-1.0.2u"
  ];
}
