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

  profiles.dev.wakatime.enable = lib.mkDefault true;

  fonts.fonts = with pkgs; [
    anonymousPro
    source-code-pro
    nerdfonts
  ];

  my.home = { config, pkgs, ... }: {
    home.sessionVariables = {
      LESS = "--RAW-CONTROL-CHARS --quit-if-one-screen";
      CARGO_HOME = "${config.xdg.cacheHome}/cargo";
      DOCKER_CONFIG = "${config.xdg.configHome}/docker";
      M2_HOME = "${config.xdg.cacheHome}/maven";
      NIX_PAGER = "less --RAW-CONTROL-CHARS --quit-if-one-screen";
    };

    home.packages = with pkgs; [
      jq # tool to extract data out from a json input (files, stdin, ...)

      # Programming
      gnumake # for the `make` program
      # Broken (2021-09-06)
      # powershell # for some rare one-off scripts and tests
      tig # navigate a git repository's log and commits in a TUI, provides sorting, filtering, etc.
      clang # for the binary tools it offers?

      wget # I prefer using curl but still useful for one-off things
      curl # make advanced http requests, fetch files, etc.
      ouch # a generic compressor/decompressor tool
      httpie # like curl/wget with a simpler cli interface
      aria # curl/wget on steroid to download files using different protocols
      lsof # shows information about opened files by processes, useful for debugging
      gitFull # contains extra stuff that I don't remember
      rsync # copy files localy and remotely
      nmap # scanner for CTF and my local network
      netcat-gnu # better than telnet
      tcpdump # see packet flows on interfaces to debug stuff
      dnsutils # dns lookups
      mtr # interactive traceroute that updates continuously
      bandwhich # see which programs are using network
      exa # a better ls with colors, tree support (it has to evaluate the entire file tree unfortunately)
      fd # find with an easier syntax (though it doesn't replace find entirely)
      fzf # used in scripts as a fuzzy matcher for passed inputs as well as `kill -9 <tab><tab>` completion
      ripgrep # grep with some nice defaults
      hexyl # binary viewer like xxd (kinda sucks though)
      tree # file list tree
      bc # terminal calculator though I prefer using a python repl or `python -c 'print(39**25)'`
      bat # a better alternative to cat with syntax highlighting
      procs # an alternative to ps to view all currently running processes (static view)
      sd # replace lines in files or lines in stdin without the "annoying" syntax of sed or awk
      du-dust # du with a tree-like listing and usage graph
      tokei # shows the number of lines of code in a folder for each language
      manix # lookup a nix function documentation or a NixOS/Home Manager option documentation
      bottom # `btm` is an htop/gotop/... alternative
      hyperfine # benchmarking tool
      htop # shows running processes with sorting or filtering
      ctop # shows running containers (supports docker, mock, runc)
      docker-compose # a nice wrapper for docker to manage multiple docker containers (for one-off projects)
      # onefetch's libresolv dependency does not build on aarch64
      (lib.mkIf (!(pkgs.stdenv.isAarch64 && pkgs.stdenv.isDarwin)) onefetch) # neofetch for a git repository : lines of code, repo, etc.
      zellij # a terminal multiplexer

      ispell # spellchecking

      github-cli # Quite useful actually

      googler # search Google from the command line and copy links

      # NixOS/nixpkgs stuff
      nixpkgs-review # review nixpkgs PR
      nix-update # quickly update a package

      # Global packages for some programming languages
      # I often open repls to test things
      nodejs
      # v Works well with my python alias to "ptipython"
      (python3.withPackages (ps: with ps; [ ptpython ipython ]))
      erlang
      rebar3
      erlang-ls

    ] ++ lib.optionals pkgs.stdenv.isLinux [
      # Broken: 2021-07-10
      # pipr # interactive tool to write pipelines
      # bubblewrap # required by pipr

      iotop # see which processes/kernel tasks are using IO

      #jetbrains.idea-community # IDE that I don't use anymore, even for Java development
      insomnia # GUI tool to test http APIs, alternative to postman and hoppscotch (formerly postwoman)
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
      defaultCommand = ''${pkgs.fd}/bin/fd --follow --type f --exclude=".git" .'';
      defaultOptions = [ "--exact" "--cycle" "--layout=reverse" ];
      # enableFishIntegration = true;
    };
    programs.zsh.initExtra = lib.mkIf (with config.programs; (!fzf.enableZshIntegration) && mcfly.enable && mcfly.enableZshIntegration) ''
      bindkey -r "^R"
      bindkey "^R" mcfly-history-widget
    '';

    # 2021-04-02: mcfly fuzzy search isn't really good
    # and I found it to be a worse alternative to FZF
    # it would also lock up from time to time trying to index my zsh history
    # making all my terminals unusable
    programs.mcfly = {
      # Disabled as of 2021-04-02, see comment above
      enable = false;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableFuzzySearch = true;
    };

    # Load an `.envrc` file in the directory into the current shell
    # Extremely useful
    # See my patch in '$PROJECT_ROOT/overlays/direnv-disable-logging-exports.patch'
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
      nix-direnv.enableFlakes = true;
      config = {
        global.disable_stdin = true;
        global.strict_env = true;
      };
    };

    # Quickly jump to directories with `z something` or `z s`
    # Learns the most frequently used directories and allows you to jump to them
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    programs.tmux = {
      enable = true;
      keyMode = "vi";
      # Use C-a
      shortcut = "a";
      baseIndex = 1;
      escapeTime = 0;

      historyLimit = 10000;

      clock24 = true;
      # customPaneNavigationAndResize = true;

      plugins = with pkgs.tmuxPlugins; [
        {
          # Show when the prefix is used in the status bar
          plugin = prefix-highlight;
        }
        {
          # Easymotion/Acejump: type 1 char to jump to a word
          plugin = jump;
        }
        {
          plugin = power-theme;
          extraConfig = ''
            set -g @tmux_power_theme 'redwine'
            set -g @tmux_power_prefix_highlight_pos 'L'
          '';
        }
      ];

      extraConfig = ''
        set -g mouse on
      '';
    };
  };
}

