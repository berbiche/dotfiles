{
  description =
    "Nicolas Berbiche's poorly organized dotfiles and computer configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:rycee/home-manager/bqv-flakes";
    #home-manager = {
    #  type = "github";
    #  ref = "module/waybar";
    #  owner = "berbiche";
    #  repo = "home-manager";
    #  flake = false;      
    #};
    nixpkgs-mozilla = { url = "github:mozilla/nixpkgs-mozilla"; flake = false; };
    nixpkgs-wayland.url = "github:colemickens/nixpkgs-wayland";
    nixpkgs-wayland.inputs.nixpkgs.follows = "nixpkgs";
    vim-theme-monokai = { url = "github:sickill/vim-monokai"; flake = false; };
    vim-theme-anderson = { url = "github:tlhr/anderson.vim"; flake = false; };
    vim-theme-synthwave84 = { url = "github:artanikin/vim-synthwave84"; flake = false; };
    vim-theme-gruvbox = { url = "github:morhetz/gruvbox"; flake = false; };
  };

  outputs = { nixpkgs, nix, self, ... }@inputs: let
    inherit (nixpkgs) lib;

    config = {
      allowUnfree = true;
    };

    mkConfig =
      { hostname
      # Primary user's username (your username)
      , username
      , hostConfiguration ? ./host + "/${hostname}.nix"
      , homeConfiguration ? ./user + "/${username}.nix"
      }:
        lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };

          pkgs = import nixpkgs {
            inherit system config;
            overlays = (lib.attrValues inputs.self.overlays) ++ [
              (import inputs.nixpkgs-mozilla)
              inputs.nixpkgs-wayland.overlay
              ({ inputs = _: _: { inherit inputs; }; })
            ];
          };

          modules = let
            # home-manager = "${inputs.home-manager}/nixos";
            inherit (inputs.home-manager.nixosModules) home-manager;

            defaults = { pkgs, ... }: {
              imports = [ ./configuration.nix hostConfiguration ];

              system.nixos.tags = [ "with-flakes" ];

              # Allow installing non-free packages by default
              nixpkgs.config.allowUnfree = true;

              # Pin nixpkgs
              nix.nixPath = [
                "nixpkgs=${nixpkgs}"
                "nixos-config=${toString ./flake.nix}"
                "nixpkgs-overlays=${toString ./overlays}"
              ];
              nix.registry.self.flake = inputs.self;
              nix.package = inputs.nix.packages.x86_64-linux.nix;
              nix.extraOptions = ''
                experimental-features = nix-command flakes
              '';


              my = {
                inherit hostname username homeConfiguration;
              };
            };
          in [ defaults home-manager ];
        };
  in {
    nixosConfigurations = {
      merovingian = mkConfig { hostname = "merovingian"; username = "nicolas"; };
      thixxos = mkConfig { hostname = "thixxos"; username = "nicolas"; };
    };

    overlays = lib.listToAttrs (map (name: {
      name = lib.removeSuffix ".nix" name;
      value = import (./overlays + "/${name}");
    }) (lib.attrNames (builtins.readDir ./overlays)));

    devShell."x86_64-linux" = let
      nixpkgs' = import nixpkgs { system = "x86_64-linux"; };
    in nixpkgs'.mkShell {
      nativeBuildInputs = with nixpkgs'; [
        nixFlakes
        fish ripgrep fd
      ];

      NIX_CONF_DIR = let
        current = nixpkgs'.lib.optionalString (builtins.pathExists /etc/nix/nix.conf)
          (builtins.readFile /etc/nix/nix.conf);
        nixConf = nixpkgs'.writeTextDir "etc/nix.conf" ''
          ${current}
          experimental-features = nix-command flakes
        '';
      in "${nixConf}/etc";

      shellHook = ''
        rebuild () {
          sudo --preserve-env=PATH --preserve-env=NIX_CONF_DIR env _NIXOS_REBUILD_REEXEC=1 \
            nixos-rebuild "$@"
        }
      '';
    };
  };
}
