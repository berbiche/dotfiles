{ config, pkgs, lib, ... }:

let
  inherit (builtins) map attrNames readDir;
  inherit (lib) filterAttrs hasSuffix;

  configs = let
    files = readDir ./.;
    filtered = filterAttrs (n: v: n != "default.nix" && (v == "directory" || (v == "regular" && hasSuffix ".nix" n)));
  in map (p: ./. + "/${p}") (attrNames (filtered files));
in
{
  imports = configs;

  profiles.dev.wakatime.enable = true;

  my.home = { config, pkgs, ... }: {
    home.sessionVariables = {
      EDITOR = "${config.programs.neovim.finalPackage}/bin/nvim";
      LESS = "--RAW-CONTROL-CHARS --quit-if-one-screen";
      CARGO_HOME = "${config.xdg.cacheHome}/cargo";
      DOCKER_CONFIG = "${config.xdg.configHome}/docker";
      M2_HOME = "${config.xdg.cacheHome}/maven";
      NIX_PAGER = "less --RAW-CONTROL-CHARS --quit-if-one-screen";
    };

    home.packages = with pkgs; [
      # cli to extract data out of json input
      jq
      # interactive tool to write pipelines
      pipr

      # Programming
      clang
      (python3.withPackages (ps: with ps; [ ptpython ipython ]))
      gnumake
      powershell
      tig

      wget curl aria
      lsof iotop
      gitFull rsync
      nmap telnet tcpdump dnsutils mtr bandwhich
      exa fd fzf ripgrep hexyl tree bc bat
      procs sd du-dust tokei manix bottom hyperfine
      htop ctop
      docker-compose
      onefetch
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      jetbrains.idea-community
      insomnia
    ];

    # Preview directory content and find directory to `cd` to
    programs.broot = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    # ctrl-t, ctrl-r, kill <tab><tab>
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = ''${pkgs.fd}/bin/fd --follow --type f --exclude="'.git'" .'';
      defaultOptions = [ "--exact" "--cycle" "--layout=reverse" ];
      # enableFishIntegration = true;
    };

    programs.mcfly = {
      enable = false;
      enableFishIntegration = true;
    };

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNixDirenvIntegration = true;
      config = {
        global.disable_stdin = true;
        global.strict_env = true;
      };
      stdlib = ''
        # Silence DIRENV variable export
        # export DIRENV_LOG_FORMAT=""
      '';
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
  };
}

