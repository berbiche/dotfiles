{ config, pkgs, lib, ... }:

{
  my.home.home.packages = with pkgs; [
    binutils
    # Edit and view hex data
    bless
    # Tool to modify web requests, automate web requests, proxy, etc.
    burpsuite
    # See the file type
    file
    # Debug binaries for reversing
    gdb
    # Reversing binaries
    ghidra-bin
    # A better (faster) dirbuster: files/directory enumeration for many protocols
    gobuster
    # Password cracker
    hashcat
    # Modify hex data
    hexedit
    # Password cracker
    john
    # Extract 7z files and a lot of other stuff
    p7zip
    # Patch binaries using dynamic libs and other stuff
    patchelf
    pwndbg
    python3Packages.binwalk
    shellcheck
    sqlmap
    stegseek
    wireshark
    # volatility
  ];

  # Volatility requires this unfortunately
  # my.home.nixpkgs.config.permittedInsecurePackages = [ "python2.7-Pillow-6.2.2" ];
}
