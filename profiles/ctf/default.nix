{ config, pkgs, lib, ... }:

{
  my.home = {
    home.packages = with pkgs; [
      wireshark
      ghidra-bin
      gdb
      pwndbg
      burpsuite
      binutils
      volatility
      p7zip
      patchelf
      shellcheck
      python3Packages.binwalk
      p7zip
    ];
  };
}
