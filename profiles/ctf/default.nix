{ config, pkgs, lib, ... }:

{
  my.home.home.packages = with pkgs; [
    wireshark
    ghidra-bin
    gdb
    pwndbg
    burpsuite
    binutils
    # volatility
    p7zip
    patchelf
    shellcheck
    python3Packages.binwalk
    hexedit
    gobuster
    file
  ];

  # Volatility requires this unfortunately
  # my.home.nixpkgs.config.permittedInsecurePackages = [ "python2.7-Pillow-6.2.2" ];
}
