{ config, pkgs, lib, ... }:

{
  home-manager.users.${config.my.username} = {
    home.packages = with pkgs; [
      wireshark
      ghidra-bin-with-go
      gdb
      pwndbg
      burpsuite
      binutils
      volatility
      p7zip
      patchelf
    ];
  };
}
