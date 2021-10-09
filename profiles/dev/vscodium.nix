{ config, lib, pkgs, isLinux, ... }:

let
  buildVs = ref@{ license ? null, ... }:
    pkgs.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = builtins.removeAttrs ref [ "license" ];
      meta = lib.optionalAttrs (license != null) { inherit license; };
    };

  # Replaces VSCodium's open-vsx with Microsoft's extension gallery
  # This is temporary
  extensionsGallery = builtins.toJSON {
    serviceUrl = "https://marketplace.visualstudio.com/_apis/public/gallery";
    itemUrl = "https://marketplace.visualstudio.com/items";
  };
  vscodium = pkgs.vscodium.overrideAttrs(old: {
    nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [ pkgs.jq ];
    installPhase = old.installPhase or "" + ''
      #FILE=$out/lib/vscode/resources/app/product.json
      FILE=$(find $out -name 'product.json' -print -quit)
      mv $FILE .
      echo "Patching product.json"
      jq <product.json >$FILE '
        with_entries(
          if .key == "extensionsGallery"
          then .value = ${extensionsGallery}
          else .
          end
        )
      '
      if [ $? -eq 0 ]; then
        echo "Patching product.json successfully"
      else
        echo "Patching product.json failed"
      fi
    '';
  });

  my-vscode-packages = {
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
    wakatime = let
      wakatime =
        (buildVs {
          name = "vscode-wakatime";
          publisher = "WakaTime";
          version = "5.0.1";
          sha256 = "YY0LlwFKeQiicNTGS5uifa9+cvr2NlFyKifM9VN2omo=";
        }).overrideAttrs (old: {
          postInstall = old.postInstall or "" + ''
            mkdir -p "$out/${old.installPrefix}/wakatime-cli"
            ln -sT "${pkgs.wakatime}/bin/wakatime" "$out/${old.installPrefix}/wakatime-cli/wakatime-cli"
          '';
        });
    in lib.mkIf config.profiles.dev.wakatime.enable wakatime;
  };

  extensions = with pkgs.vscode-extensions; [
    asvetliakov.vscode-neovim
    bbenoist.nix
    redhat.vscode-yaml
    arrterian.nix-env-selector
    ms-kubernetes-tools.vscode-kubernetes-tools
    ms-vscode-remote.remote-ssh
    xaver.clang-format
    redhat.java
    coenraads.bracket-pair-colorizer-2
    # dbaeumer.vscode-eslint
    davidanson.vscode-markdownlint
    # PDF preview using PDF.js
    tomoki1207.pdf
  ]
  ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    ms-vsliveshare.vsliveshare
    # Broken
    # ms-python.python
    llvm-org.lldb-vscode
  ]
  ++ lib.attrValues my-vscode-packages;

  package = vscodium;
  # package = pkgs.vscode;

  finalPackage =
    (pkgs.vscode-with-extensions.override {
      vscode = package;
      vscodeExtensions = extensions;
    }).overrideAttrs (old: {
      inherit (package) pname version;
    });
in
{
  my.home = { config, ... }: {
    programs.vscode = {
      enable = true;

      package = finalPackage;

      extensions = [];

      userSettings = {
        "editor.cursorSmoothCaretAnimation" = true;
        "editor.fontFamily" = "'Source Code Pro', 'Anonymous Pro', 'Droid Sans Mono', 'monospace', monospace, 'Droid Sans Fallback'";
        "editor.fontSize" = 15;
        "editor.rulers" = [ 80 100 120 ];
        "editor.smoothScrolling" = true;
        "editor.stablePeek" = true;
        "explorer.autoReveal" = false;
        "extensions.autoCheckUpdates" = false;
        "git.suggestSmartCommit" = false;
        "search.collapseResults" = "alwaysCollapse";
        "terminal.integrated.tabs.enabled" = true;
        "update.mode" = "none";
        "update.channel" = "none";
        "window.menuBarVisibility" = "toggle";
        "window.restoreWindows" = "none";
        "window.title" = "\${activeEditorShort}\${separator}\${rootName}\${separator}\${appName}";
        "workbench.activityBar.visible" = false;
        "workbench.colorTheme" = "Monokai Dimmed";
        "workbench.editor.highlightModifiedTabs" = true;
        "workbench.editor.showTabs" = true;
        "workbench.editor.tabCloseButton" = "off";
        "workbench.editor.untitled.labelFormat" = "name";
        "workbench.list.smoothScrolling" = true;

        # Extension settings
        "java.semanticHighlighting.enabled" = true;
        "vscode-neovim.neovimExecutablePaths.linux" = "${config.programs.neovim.finalPackage}/bin/nvim";

        # Language settings
        "[nix]"."editor.tabSize" = 2;
      };

      keybindings = [

      ];
    };
  } // lib.optionalAttrs isLinux {
    xdg.mimeApps = let
      desktopFile =
        if finalPackage.pname == "vscode"
        then "${finalPackage}/share/codium.desktop"
        else "${finalPackage}/share/code.desktop";
    in {
      defaultApplications = {
        "x-scheme-handler/vscodium" = [ desktopFile ];
        "x-scheme-handler/vscode" = [ desktopFile ];
        "x-scheme-handler/code-url-handler" = [ desktopFile ];
      };
      associations.added = {
        "x-scheme-handler/vscodium" = [ desktopFile ];
        "x-scheme-handler/vscode" = [ desktopFile ];
        "x-scheme-handler/code-url-handler" = [ desktopFile ];
      };
    };
  };
}
