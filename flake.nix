{
  description =
    "Nicolas Berbiche's poorly organized dotfiles and computer configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nix.url = "github:nixos/nix";
    nix-darwin.url = "github:LnL7/nix-darwin/flakes";
    home-manager.url= "github:rycee/home-manager";
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

    mkConfig =
      { platform
      , hostname
      , username
      , hostConfiguration ? ./host + "/${hostname}.nix"
      , userConfiguration ? ./user + "/${username}.nix"
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
          imports = [ hostConfiguration userConfiguration ./cachix.nix ];
          _module.args.inputs = inputs;
          _module.args.rootPath = ./.;

          environment.systemPackages = [ pkgs.cachix ];

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
          home-manager.users.${username} = { lib, ... }: {
            config = {
              # Inject inputs
              _module.args.inputs = inputs;
              _module.args.rootPath = ./.;
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
      in [ user defaults ] ++ extraModules;

    mkLinuxConfig =
      { platform, hostname, hostConfiguration ? ./host + "/${hostname}.nix", ... } @ args:
      let
        modules = mkConfig args;

        linuxDefaults = { pkgs, lib, ... }: {
          # Import home-manager/nixos version here
          imports = [ inputs.home-manager.nixosModules.home-manager ];
          system.nixos.tags = [ "with-flakes" ];
          nix = {
            # Pin nixpkgs
            nixPath = [
              "nixpkgs=${pkgs.path}"
              "nixos-config=${toString hostConfiguration}"
              "nixpkgs-overlays=${toString ./overlays}"
            ];
            allowedUsers = [ "@wheel" ];
            trustedUsers = [ "root" "@wheel" ];
            registry.self.flake = inputs.self;
            gc.dates = "daily";

            # Reduce IOnice and CPU niceness of the build daemon
            daemonIONiceLevel = 3;
            daemonNiceLevel = 10;
          };
        };
      in
        lib.nixosSystem {
          modules = [ linuxDefaults ] ++ modules;
          system = platform;
          specialArgs = { inherit inputs; };
          pkgs = nixpkgsFor.${platform};
        };

    mkDarwinConfig =
      { platform, ... } @ args: let
        modules = mkConfig args;

        darwinDefaults = { config, pkgs, lib, ... }: {
          imports = [ inputs.home-manager.darwinModules.home-manager ];
          nix.gc.user = args.username;
          nix.nixPath = [
            "nixpkgs=${pkgs.path}"
            "nixpkgs-overlays=${toString ./overlays}"
            "darwin=${inputs.nix-darwin}"
          ];
          system.checks.verifyNixPath = false;
          system.darwinVersion = lib.mkForce (
            "darwin" + toString config.system.stateVersion + "." + inputs.nix-darwin.shortRev);
          system.darwinRevision = inputs.nix-darwin.rev;
          system.nixpkgsVersion =
            "${inputs.nixpkgs.lastModifiedDate or inputs.nixpkgs.lastModified}.${inputs.nixpkgs.shortRev}";
          system.nixpkgsRelease = lib.version;
          system.nixpkgsRevision = inputs.nixpkgs.rev;
        };

        result = inputs.nix-darwin.lib.evalConfig {
          configuration = { ... }: { imports = modules ++ [ darwinDefaults ]; };
          inputs.nixpkgs = nixpkgs;
        };
      in result.system;
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
          export NIX_PATH="$NIX_PATH:darwin=${inputs.nix-darwin}"

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
