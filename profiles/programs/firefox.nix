{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.targetPlatform) isDarwin isLinux;

  # firefox versions available in nixpkgs-mozilla are already wrapped
  wrappedFirefox = pkgs.firefox-beta-bin.override {
    desktopName = "Firefox";
    icon = "firefox";
    cfg = {
      # Chromecast support through a native extension
      enableFXCastBridge = true;
    };
  };

  makeProfile = { id, settings ? null, default ? false }: {
    id = id;
    isDefault = default;
    # Many of these settings have been taken from https://github.com/ghacksuserjs/ghacks-user.js
    settings = {
      "general.useragent.locale" = "en-CA";
      "browser.search.region" = "CA";
      "browser.search.isUS" = false;
      "intl.locale.requested" = "en-CA,en,fr";
      "browser.aboutConfig.showWarning" = false;
      "browser.download.useDownloadDir" = false;

      # Keep a huge history of visited websites
      "places.history.enabled" = true;
      "places.history.expiration.max_pages" = 999999;

      # Tab-specific zoom
      "browser.zoom.siteSpecific" = false;

      # Enable suggestions with DDG
      "browser.search.suggest.enabled" = true;
      "browser.urlbar.suggest.searches" = true;
      "browser.urlbar.usepreloadedtopurls.enabled" = true;

      # Disable Firefox password storing
      "signon.rememberSignons" = false;
      "signon.autofillForms" = false;

      # Enable DRM (Widevine)
      "media.eme.enabled" = true;
      "media.gmp-widevinecdm.visible" = true;
      "media.gmp-widevinecdm.enabled" = true;

      # Enable WebRTC VA-API decoding support
      # https://bugzilla.mozilla.org/show_bug.cgi?id=1646329
      "media.ffmpeg.vaapi.enabled" = true;
      "media.ffmpeg.low-latency.enabled" = true;
      "media.navigator.mediadatadecoder_vpx_enable" = true;

      # Allow websites to output to a specific audio device
      # Leaks available audio devices (fingerprinting)
      "media.setsinkid.enable" = true;

      # UI settings
      "browser.uidensity" = 1;
      "browser.tabs.drawInTitlebar" = true;
      "browser.download.autohideButton" = false;
      "browser.download.panel.shown" = true;
      "browser.newtab.privateAllowed" = true;
      "browser.urlbar.placeholderName.private" = "Private";
      # Enable new built-in tab manager
      "browser.tabs.tabmanager.enabled" = true;
      # Theme to use
      "extensions.activeThemeID" = "firefox-compat-dark@mozilla.org";
      # Very important UI settings
      "browser.urlbar.doubleClickSelectsAll" = false;
      "browser.ctrlTab.recentlyUsedOrder" = false;
      # Disable some annoyances
      "browser.discovery.enabled" = false;
      "browser.aboutwelcome.enabled" = false;
      "browser.preferences.defaultPerformanceSettings.enabled" = false;
      "browser.uitour.enabled" = false;
      "browser.shell.checkDefaultBrowser" = false;
      # Disable recommend extensions as you browse
      "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
      # Disable recommend features as you browse
      "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
      # Force-enable xdg-desktop-portal for filepickers and other things
      "widget.use-xdg-desktop-portal" = true;

      # Prevent the browser from requesting true fullscreen
      # This allows me to personally fullscreen or not something (e.g. Youtube)
      # https://github.com/swaywm/sway/pull/4255#issuecomment-606081970
      "full-screen-api.ignore-widgets" = true;

      # UI : delay repaint when opening a new tab to reduce screen flash
      # see https://old.reddit.com/r/firefox/comments/kd12b4
      "nglayout.initialpaint.delay" = 400;

      # Acceleration settings
      # Temporarily disable (2021-10-09)
      "gfx.webrender.all" = false;
      # "layers.acceleration.force-enabled" = true;

      "widget.wayland.async-clipboard.enabled" = true;

      # Extension related settings
      "extensions.ui.dictionary.hidden" = false;
      "extensions.ui.extension.hidden" = false;
      "extensions.ui.locale.hidden" = false;

      # Tabs settings
      "browser.tabs.loadBookmarksInBackground" = true;

      # Privacy settings
      "privacy.trackingprotection.enabled" = true; # Most trackingprotection's settings are enabled by default
      "network.dns.disablePrefetch" = true;
      "network.dns.disablePrefetchFromHTTPS" = true;
      "network.predictor.enabled" = false;
      "network.prefetch-next" = false;
      "browser.urlbar.speculativeConnect.enabled" = false;
      # Disable link-mouseover opening connections
      "network.http.speculative-parallel-limit" = 0;
      "privacy.donottrackheader.enabled" = true;
      "privacy.popups.showBrowserMessage" = false;
      # Make 720p the default resolution
      "privacy.resistFingerprinting.target_video_res" = 720;
      # Disable sending data to website when leaving pages
      "beacon.enabled" = false;
      "browser.send_pings" = false;
      "browser.send_pings.require_same_host" = true;
      # "geo.provider.network.url" = "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
      # Use OS geolocation provider
      "geo.provider.use_gpsd" = true;
      "browser.ping-centre.telemetry" = false;
      "extensions.webcompat-reporter.enabled" = false;
      # Don't try to be smart about DNS requests (do not append a `.com`)
      "browser.fixup.alternate.enabled" = false;
      "browser.urlbar.trimURLs" = false;
      # https://arxiv.org/abs/1810.07304
      "security.ssl.disable_session_identifiers" = true;
      "security.ssl.errorReporting.automatic" = false;
      "security.ssl.errorReporting.enabled" = false;
      # Disable some JS/DOM APIs
      "dom.battery.enabled" = false;
      "dom.vr.enabled" = false;
      "dom.enable_performance" = false;
      "device.sensors.enabled" = false;
      "dom.gamepad.enabled" = false;

      # Safebrowsing settings
      "browser.safebrowsing.enabled" = false;
      "browser.safebrowsing.downloads.enabled" = false;
      "browser.safebrowsing.malware.enabled" = false;
      "browser.safebrowsing.phishing.enabled" = false;
      "browser.safebrowsing.downloads.remote.enabled" = false;

      # Private browsing settings
      # Disable persisting private browsing permissions to disk
      "permissions.memory_only" = true;
      # Disable private browsing memory cache from hitting the disk (memory only)
      "browser.privatebrowsing.forceMediaMemoryCache" = true;

      # Sync settings
      "services.sync.declinedEngines" = "passwords,prefs,bookmarks,addons";

      # Telemetry settings
      "toolkit.telemetry.enabled" = false;
      "toolkit.telemetry.unified" = false;
      "toolkit.telemetry.server" = "data:,";
      "toolkit.telemetry.archive.enabled" = false;
      "toolkit.telemetry.newProfilePing.enabled" = false;
      "toolkit.telemetry.shutdownPingSender.enabled" = false;
      "toolkit.telemetry.updatePing.enabled" = false;
      "toolkit.telemetry.bhrPing.enabled" = false;
      "toolkit.telemetry.firstShutdownPing.enabled" = false;
      "app.normandy.enabled" = false;
      "app.normandy.api_url" = "";
      "app.shield.optoutstudies.enabled" = true;
      "experiments.activeExperiment" = false;
      "experiments.enabled" = false;
      "experiments.supported" = false;
      "extensions.pocket.enabled" = false;

      # Extra security settings
      # 0=don't allow sub-resources to open HTTP authentication credentials dialogs
      # 1=don't allow cross-origin sub-resources '' '' ''
      # 2=allow '' '' (default)
      "network.auth.subresource-http-auth-allow" = 1;
      "security.ssl.require_safe_negotiation" = true;
      "security.tls.version.enabled-deprecated" = false;
      "network.IDN_show_punycode" = true;

    } // (lib.optionalAttrs (settings != null) settings);
  };
in
lib.mkIf isLinux {
  # Fix Firefox. See <https://mastransky.wordpress.com/2020/03/16/wayland-x11-how-to-run-firefox-in-mixed-environment/>
  home.sessionVariables = {
    MOZ_DBUS_REMOTE = "1";
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_USE_XINPUT2 = "1";
  };

  programs.firefox = {
    enable = true;
    package = wrappedFirefox;

    profiles = {
      # Profile ids need to be sequential?
      default = makeProfile { id = 0; default = true; };
      secondary = makeProfile { id = 1; };
      ternary = makeProfile { id = 2; };
      job = makeProfile { id = 3; };
    };
  };
}
