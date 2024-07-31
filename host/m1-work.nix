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
  security.pam.enableSudoTouchIdAuth = true;

  # Include Netskope's certificates
  security.pki.certificateFiles = [
    (pkgs.runCommandLocal "caa-out-of-store-symlink" {} ''
      ln -s '/Library/Application Support/Netskope/STAgent/data/nscacert.pem' $out
    '')
  ];

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
    "kerl" # used by asdf
    # Required by an upstream work tool that automatically brews install these shits
    "brotli"
    "libunistring"
    "libidn2"
    "libnghttp2"
    "libssh2"
    "openldap"
    "rtmpdump"
    "curl"
    # Aerospike
    "libev"

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
    my.config.is-work-host = true;

    home.sessionPath = [ osConfig.homebrew.brewPrefix "/opt/homebrew/sbin" ];
    home.packages = [
      pkgs.krew
      pkgs.kubectl
      pkgs.vault-bin
      pkgs.parthenon-hs
      pkgs.awscli2
      pkgs.saml2aws
    ] ++ lib.filter availableOnDarwin [
      pkgs.helm
    ];

    # Yeah...
    profiles.dev.asdf.enable = true;
  };
}
