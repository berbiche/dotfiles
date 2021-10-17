{
  description =
    "Nicolas Berbiche's poorly organized dotfiles and computer configuration";

  inputs = {
    # This input I update less frequently
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    # nixpkgs.url = "github:berbiche/nixpkgs/fix-emacs-passthru";
    # nixpkgs.url = "git+file:///home/nicolas/dev/nixpkgs";
    #nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.url = "github:berbiche/nix-darwin/stuff-i-want-merged";
    master.url = "github:nixos/nixpkgs/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    # home-manager.url= "github:nix-community/home-manager";
    home-manager.url= "github:berbiche/home-manager/my-custom-master-branch";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/nur";
    my-nur = { url = "github:berbiche/nur-packages"; flake = false; };

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    doom-emacs.url = "github:vlaci/nix-doom-emacs/develop";
    doom-emacs.inputs.emacs-overlay.follows = "emacs-overlay";
    doom-emacs.inputs.nix-straight.follows = "nix-straight";
    # Temporary fix for the emacs gcc package
    nix-straight.url = "github:vlaci/nix-straight.el/a2379105b7506094a818de1486fa8f2525854149";
    nix-straight.flake = false;
    emacs-overlay.url = "github:nix-community/emacs-overlay";

    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, ... }: let
    inherit (nixpkgs) lib;

    platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];

    forAllPlatforms = f: lib.genAttrs platforms (platform: f platform);

    nixpkgsFor = forAllPlatforms (platform: import nixpkgs {
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

    # Returns a list of Nix modules
    mkConfig = import ./top-level/mkConfig.nix;

    mkLinuxConfig = args@{ platform, hostname, ... }:
      lib.nixosSystem {
        modules = mkConfig ((removeAttrs args [ "platform" ]) // {
          isLinux = true;
          extraModules = [ ./top-level/nixos.nix ];
        });
        system = platform;
        pkgs = nixpkgsFor.${platform};
        specialArgs = specialArgs {
          inherit inputs;
          isLinux = true;
        };
      };

    mkDarwinConfig = args:
      inputs.nix-darwin.lib.darwinSystem {
        system = args.platform;
        modules = mkConfig ((removeAttrs args [ "platform" ]) // {
          isLinux = false;
          extraModules = [
            ./top-level/darwin.nix
            {
              nixpkgs.overlays = nixpkgsFor."${args.platform}".overlays;
            }
          ];
        });
        # This has to be passed here otherwise nix-darwin tries
        # to use its own very old nixpkgs
        inputs.nixpkgs = inputs.nixpkgs;
        specialArgs = specialArgs {
          # inputs are not passed as specialArgs
          # and if I override everything then nix-darwin can no longer
          # get it's own `self`
          inputs = inputs // { darwin = inputs.nix-darwin; };
          isLinux = false;
        };
      };

  in {
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

    overlays = with lib; let
      overlayFiles' = filter (hasSuffix ".nix") (attrNames (builtins.readDir ./overlays));
      overlayFiles = listToAttrs (map (name: {
        name = removeSuffix ".nix" name;
        value = import (./overlays + "/${name}");
      }) overlayFiles');
    in overlayFiles // {
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
      x86_64-for-aarch64 = final: prev: let
        inherit (prev) lib;
        pkgs-amd64-darwin = import prev.path {
          inherit (prev) config;
          localSystem = "x86_64-darwin";
        };
      in optionalAttrs (prev.stdenv.isDarwin && prev.stdenv.isAarch64) {
        #vscode = pkgs-amd64-darwin.vscode;
        #vscode-extensions = pkgs-amd64-darwin.vscode-extensions;
        #vscode-utils = pkgs-amd64-darwin.vscode-utils;
        #vscode-with-extensions = pkgs-amd64-darwin.vscode-with-extensions;
        #vscodium = pkgs-amd64-darwin.vscodium;
        nix-index-unwrapped = prev.nix-index-unwrapped.overrideAttrs (drv: rec {
          src = prev.fetchFromGitHub {
            owner = "bennofs";
            repo = "nix-index";
            rev = "5a4b3c603b837ded17845c59227dd06312562782"; 
            sha256 = "sha256:0ir9zjm49qx28a3hp0s3k6s90mjcddn8f86jyp7p3px91v4bma6c";
          };
          cargoDeps = drv.cargoDeps.overrideAttrs (lib.const {
            #name = "${drv.name}-vendor.tar.gz";
            inherit src;
            outputHash = "sha256:0nqfcklkljgqpw4mzs2ak3p5dccgw8mxfchjkkj1zrrf4xg2mgld";
          });
        });
      };
    };

    devShell = forAllPlatforms (platform: let
        pkgs = nixpkgsFor.${platform};
        sops = inputs.sops-nix.packages.${platform};
      in pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          git nixFlakes
          sops.sops-import-keys-hook
        ];

        NIX_CONF_DIR = let
          current = lib.optionalString (builtins.pathExists /etc/nix/nix.conf) (builtins.readFile /etc/nix/nix.conf);
          nixConf = pkgs.writeTextDir "etc/nix.conf" ''
            ${current}
            experimental-features = nix-command flakes
          '';
        in "${nixConf}/etc";

        sopsPGPKeyDirs = [
          "./secrets/hosts"
        ];
      });
  };
}
