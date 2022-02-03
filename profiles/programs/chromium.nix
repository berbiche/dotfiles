{ config, lib, pkgs, ... }:

{
  programs.chromium.enable = lib.mkIf pkgs.stdenv.hostPlatform.isLinux true;
  programs.chromium.package = pkgs.ungoogled-chromium.override {
    commandLineArgs = lib.concatStringsSep " " [
      "--disk-cache=$XDG_RUNTIME_DIR/chromium-cache"
      "--no-default-browser-check"
      "--no-service-autorun"
      "--disable-features=PreloadMediaEngagementData,MediaEngagementBypassAutoplayPolicies"
      # Autoplay policy
      "--document-user-activation-required"
      # Enable Wayland support
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
      # Disable global Google login
      "--disable-sync-preferences"
      # Reader mode
      "--enable-reader-mode"
      "--enable-dom-distiller"
      # Dark mode
      "--enable-features=WebUIDarkMode"
      # Security stuff
      "--disable-reading-from-canvas"
      "--no-pings"
      "--no-first-run"
      "--no-experiments"
      "--no-crash-upload"
      # Store secrets in Gnome's Keyring
      "--password-store=gnome"
      # Chromecast
      "--load-media-router-component-extension"
      # GPU stuff
      "--ignore-gpu-blocklist"
      "--enable-gpu-rasterization"
      #"--use-gl=egl"
      "--enable-zero-copy"
      # Accelerated decoding
      "--enable-features=VaapiVideoDecoder"

      "--disable-wake-on-wifi"
      "--disable-breakpad"
      "--disable-sync"
      "--disable-speech-api"
      "--disable-speech-synthesis-api"
    ];
  };

  programs.chromium.extensions = [
    # Ublock Origin
    { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }
    # Dark Reader
    { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; }
  ];
}
