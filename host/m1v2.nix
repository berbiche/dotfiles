{ config, pkgs, lib, profiles, ... }:

let
  availableOnDarwin = lib.meta.availableOn pkgs.stdenv.hostPlatform;
in
{
  imports = with profiles; [ base dev programs core-darwin ];

  my.location = {
    latitude = 45.508;
    longitude = -73.597;
  };

  nix.settings.max-jobs = 16;

  environment.systemPackages = [ pkgs.gnupg ];

  system.defaults.loginwindow.LoginwindowText = "Property of Nicolas Berbiche";

  homebrew.enable = true;
  homebrew.onActivation.upgrade = true;
  homebrew.onActivation.cleanup = "uninstall";
  homebrew.brewPrefix = "/opt/homebrew/bin";
  homebrew.taps = [
    "homebrew/cask-drivers"
  ];
  homebrew.brews = [
    # Yeah, I know...
    "autoconf" "automake" "libtool"
    "libidn" "pkg-config"
    "msgpack" "tinycdb"
    /* "libmaxminddb" */ "openssl@1.1" "libxslt" "fop"
    "kerl"

    "pcp"
  ] ++ lib.optionals (! availableOnDarwin pkgs.helm) [
    # Not packaged for Darwin in nixpkgs
    "helm@3"
  ];
  homebrew.casks = [
    "asix-ax88179"
    "kitty"
    "obs"
    "rancher"
    "spotify"
    "vagrant"

    "obsidian"

    ### Brew's Virtualbox isn't compatible with aarch64
    #"virtualbox"
    ### Ditto for yubikey-...
    #"yubico-yubikey-personalization-gui"
  ];

  system.defaults.dock = {
    orientation = "bottom";
  };

  my.home = { config, pkgs, osConfig, ... }: {
    home.sessionPath = [ osConfig.homebrew.brewPrefix "/opt/homebrew/sbin" ];
    home.packages = lib.mkMerge [
      [
        pkgs.krew
        pkgs.kubectl
        pkgs.vault-bin

        # Work
        pkgs.parthenon-hs
      ]
      (lib.mkIf (availableOnDarwin pkgs.helm) [
        pkgs.helm
      ])
    ];

    # Yeah...
    profiles.dev.asdf.enable = true;
  };
}
