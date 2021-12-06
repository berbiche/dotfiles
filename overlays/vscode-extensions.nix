final: prev: let
  inherit (prev) lib;

  buildVs = ref@{ license ? null, ... }:
    prev.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = builtins.removeAttrs ref [ "license" ];
      meta = lib.optionalAttrs (license != null) { inherit license; };
    };
in {
  vscode-extensions = prev.vscode-extensions // {
    berbiche = {
      editorconfig = buildVs {
        name = "editorconfig";
        publisher = "editorconfig";
        version = "0.16.4";
        sha256 = "sha256-j+P2oprpH0rzqI0VKt0JbZG19EDE7e7+kAb3MGGCRDk=";
      };
      erlang = buildVs {
        name = "erlang";
        publisher = "pgourlain";
        version = "0.6.9";
        sha256 = "sha256-ZoG6dKZcBGOui7LTEFgS/kMlM7jnlWiEdqcT5PF2b30=";
      };
      firefox-debugger = buildVs {
        name = "vscode-firefox-debug";
        publisher = "firefox-devtools";
        version = "2.9.2";
        sha256 = "sha256-0Cdc7i+MFiKUlVzoJvW9njT+WkuYWtylFyXg+OmUoaY=";
      };
      java-debugger = buildVs {
        name = "vscode-java-debug";
        publisher = "vscjava";
        version = "0.31.0";
        sha256 = "sha256-PsddtpwaK070LFtkOIP4ddE/SUmHgfLZZozjyYQHsz0=";
      };
      wakatime = (buildVs {
        name = "vscode-wakatime";
        publisher = "WakaTime";
        version = "17.1.0";
        sha256 = "sha256-/DfyYCZnyScvLmWLgatX1tL/3ndh3pz7FeDY/KxC+Jw=";
      }).overrideAttrs (old: {
        postInstall = old.postInstall or "" + ''
            mkdir -p "$out/${old.installPrefix}/wakatime-cli"
            ln -sT "${prev.wakatime}/bin/wakatime" "$out/${old.installPrefix}/wakatime-cli/wakatime-cli"
          '';
      });
    };
  };
}
