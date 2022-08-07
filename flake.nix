{
  description =
    "Nicolas Berbiche's poorly organized dotfiles and computer configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    # nixpkgs.url = "git+file:///home/nicolas/dev/nixpkgs";
    master.url = "github:nixos/nixpkgs/master";
    nix-darwin = {
      # url = "github:LnL7/nix-darwin";
      url = "github:berbiche/nix-darwin/stuff-i-want-merged";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url= "github:berbiche/home-manager/my-custom-master-branch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/nur";
    my-nur = { url = "github:berbiche/nur-packages"; flake = false; };

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    doom-emacs-source = { url = "github:hlissner/doom-emacs/master"; flake = false; };
    emacs-overlay.url = "github:nix-community/emacs-overlay";

    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, ... }: let
    inherit (nixpkgs) lib;

    platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];

    forAllPlatforms = f: lib.genAttrs platforms (platform: f platform);

    nixpkgsFor = forAllPlatforms (platform: let
      # I need to submit a PR with this patch
      pkgs' = import nixpkgs { system = platform; };
      patchedNixpkgs = pkgs'.applyPatches {
        name = "patched-nixpkgs";
        src = nixpkgs;
        patches = [
          (builtins.path { path = ./overlays/xserver-patches.patch; })
          # (pkgs'.fetchpatch {
          #   name = "noisetorch-0.12.0.patch";
          #   url = "https://github.com/NixOS/nixpkgs/commit/74ed89f2439f1ccc12da0517fe7a573a4143c9ed.patch";
          #   sha256 = "sha256-1LFOjdWvBx2OQRfxI7kvaHx7G54QT2d+HdU9vOrQkVc=";
          # })
        ];
      };
    in import patchedNixpkgs {
      system = platform;
      overlays = builtins.attrValues self.overlays;
      config.allowUnfree = true;
    });

    specialArgs = extraArgs:
      let
        args = self: {
          profiles = import ./profiles { inherit (self) isLinux; };
          isLinux = self.isLinux;
          isDarwin = !self.isLinux;
          rootPath = ./.;
        } // extraArgs;
      in
      lib.fix args;

    # mkConfig :: (args :: {}) -> [ modules ]
    mkConfig = import ./top-level/mkConfig.nix;

    # We don't use nixpkgs' `lib.nixosSystem` because patches applied
    # to NixOS modules are not visible from this function exposed in their flake.
    # The solution is to import eval-config.nix directly.
    mkLinuxConfig = args@{ platform, hostname, stateVersion ? "22.05", ... }: let
      pkgs = nixpkgsFor.${platform};
      lib = pkgs.lib;
    in import "${pkgs.path}/nixos/lib/eval-config.nix" {
        inherit pkgs;
        system = platform;
        modules = mkConfig ((removeAttrs args [ "platform" ]) // {
          isLinux = true;
          extraModules = [ ./top-level/nixos.nix ];
        }) ++ [{
          system.stateVersion = stateVersion;
          # This module is part of the upstream `lib.nixosSystem`
          # and needs to be replicated here manually.
          system.nixos.versionSuffix =
            ".${lib.substring 0 8 (nixpkgs.lastModifiedDate or nixpkgs.lastModified or "19700101")}.${nixpkgs.shortRev or "dirty"}";
          system.nixos.revision = lib.mkIf (nixpkgs ? rev) nixpkgs.rev;
        }];
        specialArgs = specialArgs {
          inherit inputs;
          lib = self.lib pkgs;
          isLinux = true;
        };
      };

    mkDarwinConfig = args:
      inputs.nix-darwin.lib.darwinSystem {
        system = args.platform;
        modules = mkConfig ((removeAttrs args [ "platform" ]) // {
          isLinux = false;
          extraModules = [ ./top-level/darwin.nix ];
        });
        # This has to be passed here otherwise nix-darwin tries
        # to use its own very old nixpkgs
        inputs.nixpkgs = inputs.nixpkgs;
        specialArgs = specialArgs {
          # inputs are not passed as specialArgs
          # and if I override everything then nix-darwin can no longer
          # get it's own `self`
          inputs = inputs // { darwin = inputs.nix-darwin; };
          pkgs = nixpkgsFor.${args.platform}.pkgs;
          lib = self.lib nixpkgsFor.${args.platform};
          isLinux = false;
        };
      };

    # Linux-only Home Manager configurations
    mkHomeManagerConfig = args@{ platform, username, extraProfiles ? [ ], ... }:
      inputs.home-manager.lib.homeManagerConfiguration (let
        pkgs = nixpkgsFor."x86_64-linux";
        isLinux = true;
        profiles = import ./profiles { inherit isLinux; };
        extraProfiles' = map (x: profiles.home-manager.${x}) extraProfiles;
      in rec {
        inherit (args) username;
        inherit pkgs; # to pull in my overlays
        system = args.platform;
        homeDirectory = args.homeDirectory or "/home/${args.username}";
        stateVersion = "22.05";
        extraSpecialArgs = rec {
          inherit inputs isLinux;
          lib = self.lib pkgs;
          rootPath = ./.;
          isDarwin = !isLinux;
        };
        configuration = { ... }: {
          imports = with profiles.home-manager; [
            dev
          ]
          ++ extraProfiles';
        };
        extraModules = [
          ./top-level/home-manager-options.nix
          (args.hostConfiguration or { })
          (args.userConfiguration or { })
          {
            targets.genericLinux.enable = true;
            programs.home-manager.enable = true;
          }
        ];
      });

  in {
    lib = pkgs:
      (import ./top-level/lib.nix { lib = pkgs.lib; pkgs = pkgs; })
        .extend (_: _: { inherit (inputs.home-manager.lib) hm; } );

    nixosConfigurations = {
      mero = mkLinuxConfig {
        hostname = "mero";
        username = "nicolas";
        platform = "x86_64-linux";
      };
      t580 = mkLinuxConfig {
        hostname = "t580";
        username = "nicolas";
        platform = "x86_64-linux";
      };
      vm = mkLinuxConfig {
        hostname = "virtualmachine";
        username = "nicolas";
        platform = "x86_64-linux";
      };
    };

    darwinConfigurations = {
      PC335 = mkDarwinConfig {
        hostname = "PC335";
        username = "n.berbiche";
        platform = "x86_64-darwin";
        hostConfiguration = ./host/macos.nix;
        userConfiguration = ./user/nicolas.nix;
      };
      m1 = mkDarwinConfig {
        hostname = "m1";
        username = "nberbiche";
        platform = "aarch64-darwin";
        hostConfiguration = ./host/m1.nix;
        userConfiguration = ./user/nicolas.nix;
      };
    };

    homeConfigurations = {
      blackarch = mkHomeManagerConfig {
        hostname = "blackarch";
        username = "blackarch";
        platform = "x86_64-linux";
        hostConfiguration = ./host/blackarch.nix;
      };
    };

    overlays = with lib; let
      overlayFiles' = filter (hasSuffix ".nix") (attrNames (builtins.readDir ./overlays));
      overlayFiles = listToAttrs (map (name: {
        name = removeSuffix ".nix" name;
        value = import (./overlays + "/${name}");
      }) overlayFiles');
    in overlayFiles // {
      lib = _: prev: { lib = self.lib prev; };
      nixpkgs-wayland = inputs.nixpkgs-wayland.overlay;
      emacs = inputs.emacs-overlay.overlay;
      # neovim-nightly = inputs.neovim-nightly.overlay;
      nur = inputs.nur.overlay;
      manual = final: prev: {
        # nur = import inputs.nur { nurpkgs = final; pkgs = final; };
        my-nur = import inputs.my-nur { pkgs = final; };
        nixpkgs-wayland = inputs.nixpkgs-wayland.overlay final prev;
        master = import inputs.master {
          system = prev.system;
          #overlays = self.overlays;
          config = prev.config;
        };
      };
      darwin = final: prev: prev.lib.optionalAttrs (prev.stdenv.hostPlatform.isDarwin) {
        # The package always fails to build on Darwin,
        # so just disable it and use the cask instead
        kitty = prev.runCommandLocal "dummy" { } "mkdir -p $out";
        # FIXME: https://github.com/NixOS/nixpkgs/issues/168984
        golangci-lint = prev.golangci-lint.override {
          buildGoModule = prev.buildGoModule;
        };
      };
      x86_64-for-aarch64 = final: prev: let
        inherit (prev) lib;
        pkgs-amd64-darwin = import prev.path {
          inherit (prev) config;
          localSystem = "x86_64-darwin";
        };
      in optionalAttrs (prev.stdenv.hostPlatform.isDarwin && prev.stdenv.hostPlatform.isAarch64) {
        #vscode = pkgs-amd64-darwin.vscode;
        #vscode-extensions = pkgs-amd64-darwin.vscode-extensions;
        #vscode-utils = pkgs-amd64-darwin.vscode-utils;
        #vscode-with-extensions = pkgs-amd64-darwin.vscode-with-extensions;
        #vscodium = pkgs-amd64-darwin.vscodium;
      };
    };

    devShell = forAllPlatforms (platform: let
      pkgs = nixpkgsFor.${platform};
      sops = inputs.sops-nix.packages.${platform};
      NIX_CONF_DIR = (pkgs.writeTextDir "etc/nix.conf" ''
        experimental-features = nix-command flakes

        !include /etc/nix/nix.conf
        # include /etc/nix/doesnt-exist-nix.conf
      '') + "/etc";
    in pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        git nixFlakes
        sops.sops-import-keys-hook
      ];

      sopsPGPKeyDirs = [
        "./secrets/hosts"
      ];

      shellHook = ''
        export NIX_CONF_DIR=${NIX_CONF_DIR}
      '';
    });
  };
}
