{
  description =
    "Nicolas Berbiche's poorly organized dotfiles and computer configuration";

  inputs = {
    # This input I update less frequently
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    # nixpkgs.url = "github:berbiche/nixpkgs";
    # nixpkgs.url = "git+file:///home/nicolas/dev/nixpkgs";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    # home-manager.url= "github:berbiche/home-manager/temporary-shared-modules-fix";
    home-manager.url= "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # I don't need to pin Home Manager's nixpkgs because it inherits
    # the nixpkgs version from nix-darwin/nixos
    #home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur = { url = "github:nix-community/nur"; flake = false; };
    my-nur = { url = "github:berbiche/nur-packages"; flake = false; };
    my-nixpkgs.url = "github:berbiche/nixpkgs/init-xfce4-i3-workspaces-plugin";

    doom-emacs.url = "github:vlaci/nix-doom-emacs";
    doom-emacs.inputs.emacs-overlay.follows = "emacs-overlay";
    emacs-overlay.url = "github:nix-community/emacs-overlay";

    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-wayland = {
      url = "github:colemickens/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vim-theme-monokai = { url = "github:sickill/vim-monokai"; flake = false; };
    vim-theme-anderson = { url = "github:tlhr/anderson.vim"; flake = false; };
    vim-theme-synthwave84 = { url = "github:artanikin/vim-synthwave84"; flake = false; };
    vim-theme-gruvbox = { url = "github:morhetz/gruvbox"; flake = false; };
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
          # This could import the whole tree if evaluated?, including ignored files?
          rootPath = ./.;
        } // extraArgs;
      in
      lib.fix args;

    mkConfig =
      { hostname
      , username
      , isLinux
      , hostConfiguration ? ./host + "/${hostname}.nix"
      , userConfiguration ? ./user + "/${username}.nix"
      , extraModules ? [ ]
      }:
      let
        defaults = { config, pkgs, lib, ... }: {
          imports = [ hostConfiguration userConfiguration ./cachix.nix ];

          environment.systemPackages = [ pkgs.cachix ];

          networking.hostName = lib.mkDefault hostname;

          nixpkgs.config.allowUnfree = true;
          nix = {
            package = pkgs.nixFlakes;
            extraOptions = ''
              experimental-features = nix-command flakes
            '';
            # Automatic GC of nix files
            gc = {
              automatic = true;
              options = "--delete-older-than 10d";
            };
          };

          # My custom user settings
          my = { inherit username; };

          home-manager = {
            useUserPackages = true;
            useGlobalPkgs = true;
            verbose = true;
          };
          home-manager.extraSpecialArgs = {
            isLinux = isLinux;
            isDarwin = !isLinux;
            # Inject inputs
            inputs = inputs;
            rootPath = ./.;
          };
          home-manager.sharedModules = [
            {
              # Specify home-manager version compability
              home.stateVersion = "21.05";
              # Use the new systemd service activation/deactivation tool
              # See https://github.com/nix-community/home-manager/pull/1656
              systemd.user.startServices = "sd-switch";
            }
          ];
        };
      in [ ./module.nix defaults ] ++ extraModules;

    mkLinuxConfig =
      { platform, hostname, hostConfiguration ? ./host + "/${hostname}.nix", ... } @ args:
      let
        modules = mkConfig ((removeAttrs args [ "platform" ]) // { isLinux = true; });

        linuxDefaults = { pkgs, lib, ... }: {
          # Import home-manager/nixos version here
          imports = [ inputs.home-manager.nixosModules.home-manager ./lib.nix ];
          system.nixos.tags = [ "with-flakes" ];
          nix = {
            # Pin nixpkgs for older Nix tools
            nixPath = [ "nixpkgs=${pkgs.path}" ];
            allowedUsers = [ "@wheel" ];
            trustedUsers = [ "root" "@wheel" ];

            registry = {
              self.flake = inputs.self;
              nixpkgs.flake = inputs.nixpkgs;
              nixpkgs-wayland.flake = inputs.nixpkgs-wayland;
            };

            # Run weekly garbage collection to reduce store size
            gc.dates = "weekly";
            # Optimize (hardlink duplicates) store automatically
            autoOptimiseStore = true;

            # Reduce IOnice and CPU niceness of the build daemon
            daemonIONiceLevel = 3;
            daemonNiceLevel = 10;
          };
        };
      in
        lib.nixosSystem {
          modules = [ linuxDefaults ] ++ modules;
          system = platform;
          pkgs = nixpkgsFor.${platform};
          specialArgs = specialArgs {
            inherit inputs;
            isLinux = true;
          };
        };

    mkDarwinConfig = args:
      let
        modules = mkConfig ((removeAttrs args [ "platform" ]) // { isLinux = false; });
        nixpkgs = inputs.nixpkgs-darwin;

        darwinDefaults = { config, pkgs, lib, ... }: {
          imports = [ inputs.home-manager.darwinModules.home-manager ];
          nix.gc.user = args.username;
          nix.nixPath = [
            "nixpkgs=${pkgs.path}"
            "darwin=${inputs.nix-darwin}"
          ];
          system.checks.verifyNixPath = false;
          system.darwinVersion = lib.mkForce (
            "darwin" + toString config.system.stateVersion + "." + inputs.nix-darwin.shortRev);
          system.darwinRevision = inputs.nix-darwin.rev;
          system.nixpkgsVersion =
            "${nixpkgs.lastModifiedDate or nixpkgs.lastModified}.${nixpkgs.shortRev}";
          system.nixpkgsRelease = lib.version;
          system.nixpkgsRevision = nixpkgs.rev;
        };
      in
        inputs.nix-darwin.lib.darwinSystem {
          modules = modules ++ [ darwinDefaults ];
          inputs.nixpkgs = nixpkgs;
          specialArgs = specialArgs {
            inherit inputs;
            isLinux = true;
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

    overlays = let
      overlayFiles' = lib.filter (lib.hasSuffix ".nix") (lib.attrNames (builtins.readDir ./overlays));
      overlayFiles = lib.listToAttrs (map (name: {
        name = lib.removeSuffix ".nix" name;
        value = import (./overlays + "/${name}");
      }) overlayFiles');
    in overlayFiles // {
      nixpkgs-wayland = inputs.nixpkgs-wayland.overlay;
      emacsPgtk = inputs.emacs-overlay.overlay;
      neovim-nightly = inputs.neovim-nightly.overlay;
      # nur = inputs.nur.overlay;
      nur = final: _prev: {
        nur = import inputs.nur { nurpkgs = final; pkgs = final; };
      };
      my-nur = final: _prev: {
        my-nur = import inputs.my-nur { pkgs = final; };
      };
    };

    devShell = forAllPlatforms (platform: let
        pkgs = nixpkgsFor.${platform};
      in pkgs.mkShell {
        nativeBuildInputs = with pkgs; [ git nixFlakes ];

        NIX_CONF_DIR = let
          current = lib.optionalString (builtins.pathExists /etc/nix/nix.conf) (builtins.readFile /etc/nix/nix.conf);
          nixConf = pkgs.writeTextDir "etc/nix.conf" ''
            ${current}
            experimental-features = nix-command flakes
          '';
        in "${nixConf}/etc";
      });
  };
}
