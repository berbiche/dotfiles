{
  description =
    "Nicolas Berbiche's poorly organized dotfiles and computer configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nix.url = "github:nixos/nix";
    # nix-darwin.url = "github:berbiche/nix-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/flakes";
    #home-manager = { url = "github:rycee/home-manager"; flake = false; };
    home-manager = { url = "github:berbiche/home-manager/fix-kanshi-exec"; flake = false; };
    nixpkgs-mozilla = { url = "github:mozilla/nixpkgs-mozilla"; flake = false; };
    nixpkgs-wayland = {
      url = "github:colemickens/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-firefox-pipewire.url = "github:colemickens/nixpkgs/nixpkgs-firefox-pipewire";
    vim-theme-monokai = { url = "github:sickill/vim-monokai"; flake = false; };
    vim-theme-anderson = { url = "github:tlhr/anderson.vim"; flake = false; };
    vim-theme-synthwave84 = { url = "github:artanikin/vim-synthwave84"; flake = false; };
    vim-theme-gruvbox = { url = "github:morhetz/gruvbox"; flake = false; };
  };

  outputs = { nixpkgs, self, ... }@inputs: let
    inherit (nixpkgs) lib;

    platforms = [ "x86_64-linux" "x86_64-darwin" ];

    forAllPlatforms = f: lib.genAttrs platforms (platform: f platform);

    nixpkgsFor = forAllPlatforms (platform: import nixpkgs {
      system = platform;
      overlays = builtins.attrValues self.overlays;
      config.allowUnfree = true;
    });

    # inherit (inputs.nix-darwin.darwin { 
    #   system = "x86_64-darwin";
    #   pkgs = nixpkgsFor."x86_64-darwin";
    #   configuration = null;
    #   useProvidedPkgs = true;
    # }) darwinSystem;

    darwinSystem = inputs.nix-darwin.lib.evalConfig {  };

    mkConfig =
      { platform
      , hostname
      , username
      , hostConfiguration ? ./host + "/${hostname}.nix"
      , homeConfiguration ? ./user + "/${username}.nix"
      , extraModules ? [ ]
      }:
      let
        user = { ... }: {
          options.my = with lib; {
            username = mkOption {
              type = types.str;
              description = "Primary user username";
              example = "nicolas";
              readOnly = true;
            };
          };
        };

        defaults = { pkgs, lib, stdenv, ... }: {
          imports = [ hostConfiguration ];
          nixpkgs.config.allowUnfree = true;
          nix = {
            # Pin nixpkgs
            nixPath = [
              "nixpkgs=${pkgs.path}"
              "nixos-config=${toString hostConfiguration}"
              "nixpkgs-overlays=${toString ./overlays}"
            ];
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

          home-manager.users.${username} = { lib, ... }: {
            config = {
              # Inject inputs
              _module.args.inputs = inputs;
              # Specify home-manager version compability
              home.stateVersion = "20.09";
            };

            options.my.identity = {
              name = lib.mkOption {
                type = lib.types.str;
                description = "Fullname";
              };
              email = lib.mkOption {
                type = lib.types.str;
                description = "Email";
              };
            };
          };
        };

        home-config = { ... }: {
          home-manager = {
            users.${username} = homeConfiguration;
            useUserPackages = lib.mkForce true;
          };
        };
      in [ user defaults home-config ] ++ extraModules;

    mkLinuxConfig =
      { platform, ... } @ args: let
        modules = mkConfig args;
        linuxDefaults = { pkgs, lib, ... }: {
          # Import home-manager/nixos version here
          imports = [ ./cachix.nix "${inputs.home-manager}/nixos" ];
          environment.systemPackages = [ pkgs.cachix ];
          system.nixos.tags = [ "with-flakes" ];
          nix = {
            allowedUsers = [ "@wheel" ];
            trustedUsers = [ "root" "@wheel" ];
            registry.self.flake = inputs.self;
            gc.dates = "daily";
          };
          home-manager = {
            useGlobalPkgs = true;
            verbose = true;
          };
        };
      in
        lib.nixosSystem {
          inherit modules;
          system = platform;
          specialArgs = { inherit inputs; };
          nixpkgs = nixpkgsFor.${platform};
        };

    mkDarwinConfig =
      { platform, ... } @ args: let
        modules = mkConfig args;
        darwinDefaults = { ... }: {
          imports = [ "${inputs.home-manager}/nix-darwin" ];
          home-manager.useUserPackages = true;
          nix.gc.user = args.username;
        };
        result = inputs.nix-darwin.lib.evalConfig {
          configuration = { ... }: { imports = modules ++ [ darwinDefaults ]; };
          inputs.nixpkgs = nixpkgs;
        };
      in result.system;
  in {
    nixosConfigurations = {
      merovingian = mkLinuxConfig { hostname = "merovingian"; username = "nicolas"; platform = "x86_64-linux"; };
      thixxos = mkLinuxConfig { hostname = "thixxos"; username = "nicolas"; platform = "x86_64-linux"; };
    };

    darwinConfigurations = {
      pc335 = mkDarwinConfig {
        hostname = "PC335";
        username = "n.berbiche";
        platform = "x86_64-darwin";
        hostConfiguration = ./host/macos.nix;
        homeConfiguration = ./user/nicolas.nix;
      };
    };

    overlays = let
      overlayFiles = lib.listToAttrs (map (name: {
        name = lib.removeSuffix ".nix" name;
        value = import (./overlays + "/${name}");
      }) (lib.attrNames (builtins.readDir ./overlays)));
    in overlayFiles // {
      nixpkgs-wayland = inputs.nixpkgs-wayland.overlay;
      nixpkgs-mozilla = import inputs.nixpkgs-mozilla;
      firefox-pipewire = (final: prev: {
        firefox = let
          pkgs = import inputs.nixpkgs-firefox-pipewire {
            # How should I specify the system to use here?
            system = lib.head platforms;
            config.allowUnfree = true;
          };
        in pkgs.firefox;
      });
    };

    devShell = forAllPlatforms (platform: let
        nixpkgs = nixpkgsFor.${platform};
      in nixpkgs.mkShell {
        nativeBuildInputs = with nixpkgs; [ git nixFlakes ];

        NIX_CONF_DIR = let
          current = nixpkgs.lib.optionalString (builtins.pathExists /etc/nix/nix.conf)
          (builtins.readFile /etc/nix/nix.conf);
          nixConf = nixpkgs.writeTextDir "opt/nix.conf" ''
            ${current}
            experimental-features = nix-command flakes
          '';
        in "${nixConf}/opt";

        shellHook = ''
          rebuild () {
            # _NIXOS_REBUILD_REEXEC is necessary to force nixos-rebuild to use the nix binary in $PATH
            # otherwise the initial installation would fail
            sudo --preserve-env=PATH --preserve-env=NIX_CONF_DIR _NIXOS_REBUILD_REEXEC=1 \
              nixos-rebuild "$@"
          }
        '';
      });
  };
}
