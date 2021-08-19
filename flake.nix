{
  description =
    "Nicolas Berbiche's poorly organized dotfiles and computer configuration";

  inputs = {
    # This input I update less frequently
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    # nixpkgs.url = "github:berbiche/nixpkgs/fix-emacs-passthru";
    # nixpkgs.url = "git+file:///home/nicolas/dev/nixpkgs";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url= "github:nix-community/home-manager";
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
      url = "github:colemickens/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { nixpkgs, self, ... }: let
    inherit (nixpkgs) lib;

    platforms = [ "x86_64-linux" "x86_64-darwin" ];

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
        modules = mkConfig ((removeAttrs args [ "platform" ]) // {
          isLinux = false;
          extraModules = [{
            nixpkgs.overlays = builtins.attrValues self.overlays;
          }];
        });
        inputs.nixpkgs = inputs.nixpkgs;
        specialArgs = specialArgs {
          inputs = inputs // { darwin = inputs.nix-darwin; };
          isLinux = false;
        };
      };

  in {
    nixosConfigurations = {
      merovingian = mkLinuxConfig {
        hostname = "merovingian";
        username = "nicolas";
        platform = "x86_64-linux";
      };
      thixxos = mkLinuxConfig {
        hostname = "thixxos";
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
      pc335 = mkDarwinConfig {
        hostname = "PC335";
        username = "n.berbiche";
        platform = "x86_64-darwin";
        hostConfiguration = ./host/macos.nix;
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
      neovim-nightly = inputs.neovim-nightly.overlay;
      nur = inputs.nur.overlay;
      manual = final: prev: {
        # nur = import inputs.nur { nurpkgs = final; pkgs = final; };
        my-nur = import inputs.my-nur { pkgs = final; };
        nixpkgs-wayland = inputs.nixpkgs-wayland.overlay final prev;
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
