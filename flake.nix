{
  description =
    "Nicolas Berbiche's poorly organized dotfiles and computer configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # home-manager.url = "github:rycee/home-manager/bqv-flakes";
    home-manager = {
      type = "github";
      ref = "module/waybar";
      owner = "berbiche";
      repo = "home-manager";
      flake = false;
    };
    nixpkgs-mozilla = {
      type = "github";
      ref = "master";
      owner = "mozilla";
      repo = "nixpkgs-mozilla";
      flake = false;
    };
    nixpkgs-wayland.url = "github:colemickens/nixpkgs-wayland";
    nixpkgs-wayland.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { home-manager, nixpkgs, nix, self, ... }@inputs: let
    inherit (nixpkgs) lib;

    mkConfig =
      { hostname
      # Primary user's username (your username)
      , username
      , hostConfiguration ? ./nixos/host + "/${hostname}.nix"
      , homeConfiguration ? ./user + "/${username}.nix"
      }:
        lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = let
            home = "${home-manager}/nixos";

            overlays = import ./overlays.nix;

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
          in [ defaults home overlays ];
        };
  in {
    nixosConfigurations = {
      merovingian = mkConfig { hostname = "merovingian"; username = "nicolas"; };
      thixxos = mkConfig { hostname = "thixxos"; username = "nicolas"; };
    };

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
    };
  };
}
