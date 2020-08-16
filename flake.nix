{
  description =
    "Nicolas Berbiche's poorly organized dotfiles and computer configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    # Nix build failure on current master
    nix.url = "github:nixos/nix/a79b6ddaa5dd5960da845d1b8d3c80601cd918a4";
    home-manager = { url = "github:rycee/home-manager"; flake = false; };
    nixpkgs-mozilla = { url = "github:mozilla/nixpkgs-mozilla"; flake = false; };
    nixpkgs-wayland.url = "github:colemickens/nixpkgs-wayland";
    nixpkgs-wayland.inputs.nixpkgs.follows = "nixpkgs";
    vim-theme-monokai = { url = "github:sickill/vim-monokai"; flake = false; };
    vim-theme-anderson = { url = "github:tlhr/anderson.vim"; flake = false; };
    vim-theme-synthwave84 = { url = "github:artanikin/vim-synthwave84"; flake = false; };
    vim-theme-gruvbox = { url = "github:morhetz/gruvbox"; flake = false; };
  };

  outputs = { nixpkgs, self, ... }@inputs: let
    inherit (nixpkgs) lib;

    config = {
      allowUnfree = true;
    };

    platforms = [ "x86_64-linux" ];

    forAllPlatforms = f: lib.genAttrs platforms (platform: f platform);

    nixpkgsFor = forAllPlatforms (platform: import nixpkgs {
      system = platform;
      overlays = builtins.attrValues self.overlays;
      config.allowUnfree = true;
    });

    mkConfig =
      { platform
      , hostname
      # Primary user's username (your username)
      , username
      , hostConfiguration ? ./host + "/${hostname}.nix"
      , homeConfiguration ? ./user + "/${username}.nix"
      }:
        lib.nixosSystem rec {
          system = platform;
          specialArgs = { inherit inputs; };
          pkgs = nixpkgsFor.${platform};

          modules = let
            home-manager = "${inputs.home-manager}/nixos";
            # inherit (inputs.home-manager.nixosModules) home-manager;

            defaults = { pkgs, ... }: {
              imports = [ ./configuration.nix hostConfiguration ];

              system.nixos.tags = [ "with-flakes" ];

              environment.systemPackages = [ pkgs.cachix ];
              nixpkgs.config.allowUnfree = true;
              nix = {
                allowedUsers = [ "@wheel" ];
                trustedUsers = [ "root" "@wheel" ];
                # Pin nixpkgs
                nixPath = [
                  "nixpkgs=${pkgs.path}"
                  "nixos-config=${toString ./configuration.nix}"
                  "nixpkgs-overlays=${toString ./overlays}"
                ];
                registry.self.flake = inputs.self;
                package = pkgs.nixFlakes;
                extraOptions = ''
                  experimental-features = nix-command flakes
                '';
                # Automatic GC of nix files
                gc = {
                  automatic = true;
                  dates = "daily";
                  options = "--delete-older-than 10d";
                };
              };

              my = {
                inherit hostname username;
              };

              home-manager.users.${username} = { lib, ... }: {
                config = {
                  # Inject inputs
                  _module.args.inputs = inputs;
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

            user = { ... }: {
              home-manager = {
                users.${username} = homeConfiguration;
                useUserPackages = true;
                useGlobalPkgs = true;
                verbose = true;
              };
            };
          in [ defaults user home-manager ];
        };
  in {
    packages = forAllPlatforms (platform: {
      nixosConfigurations = {
        merovingian = mkConfig { hostname = "merovingian"; username = "nicolas"; inherit platform; };
        thixxos = mkConfig { hostname = "thixxos"; username = "nicolas"; inherit platform; };
      };
    });

    overlays = let
      overlayFiles = lib.listToAttrs (map (name: {
        name = lib.removeSuffix ".nix" name;
        value = import (./overlays + "/${name}");
      }) (lib.attrNames (builtins.readDir ./overlays)));
    in overlayFiles // {
      nixpkgs-wayland = inputs.nixpkgs-wayland.overlay;
      nixpkgs-mozilla = import inputs.nixpkgs-mozilla;
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
