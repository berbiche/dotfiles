{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isAarch64 isDarwin isLinux;

  configs = let
    files = builtins.readDir ./.;
    filtered = lib.filterAttrs (n: v: n != "default.nix" && (v == "directory" || (v == "regular" && lib.hasSuffix ".nix" n)));
  in map (p: ./. + "/${p}") (builtins.attrNames (filtered files));
in
{
  imports = configs;

  home.sessionVariables = {
    LESS = "--RAW-CONTROL-CHARS --quit-if-one-screen";
    CARGO_HOME = "${config.xdg.cacheHome}/cargo";
    DOCKER_CONFIG = "${config.xdg.configHome}/docker";
    M2_HOME = "${config.xdg.cacheHome}/maven";
    NIX_PAGER = "less --RAW-CONTROL-CHARS --quit-if-one-screen";
  };

  # Alias jq to the go version of the tool
  home.shellAliases."jq" = "gojq";
  home.packages = with pkgs; [
    gojq # tool to extract data out from a json input (files, stdin, ...)
    fq # like jq but for any binary format
    yq-go # like jq for yaml
    fx # equivalent of piping json to `less` with the ability to minimize nodes

    # Programming
    gnumake # for the `make` program
    # Broken (2021-09-06)
    # powershell # for some rare one-off scripts and tests
    tig # navigate a git repository's log and commits in a TUI, provides sorting, filtering, etc.
    # (lib.lowPrio clang) # for the binary tools it offers?

    wget # I prefer using curl but still useful for one-off things
    curl # make advanced http requests, fetch files, etc.
    ouch # a generic compressor/decompressor tool
    # httpie # like curl/wget with a simpler cli interface
    aria # curl/wget on steroid to download files using different protocols
    lsof # shows information about opened files by processes, useful for debugging
    gitFull # contains extra stuff that I don't remember
    rsync # copy files localy and remotely
    nmap # scanner for CTF and my local network
    netcat-gnu # better than telnet
    socat # unix socket connections, etc.
    tcpdump # see packet flows on interfaces to debug stuff
    ## dnsutils does not build on aarch64 with the version of Nixpkgs I use because jemalloc does not build
    # dnsutils # dns lookups
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
    (lib.mkIf (!isDarwin || isAarch64) procs) # an alternative to ps to view all currently running processes (static view)
    sd # replace lines in files or lines in stdin without the "annoying" syntax of sed or awk
    du-dust # du with a tree-like listing and usage graph
    ncdu # interactive du
    tokei # shows the number of lines of code in a folder for each language
    manix # lookup a nix function documentation or a NixOS/Home Manager option documentation
    bottom # `btm` is an htop/gotop/... alternative
    hyperfine # benchmarking tool
    htop # shows running processes with sorting or filtering
    ctop # shows running containers (supports docker, mock, runc)
    docker-compose # a nice wrapper for docker to manage multiple docker containers (for one-off projects)
    # onefetch's libresolv dependency does not build on aarch64
    (lib.mkIf (!(isAarch64 && isDarwin)) onefetch) # neofetch for a git repository : lines of code, repo, etc.

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

  ] ++ lib.optionals isLinux [
    nix-top # status of packages being built

    # Broken: 2021-07-10
    # pipr # interactive tool to write pipelines
    # bubblewrap # required by pipr

    iotop # see which processes/kernel tasks are using IO

    #jetbrains.idea-community # IDE that I don't use anymore, even for Java development
    insomnia # GUI tool to test http APIs, alternative to postman and hoppscotch (formerly postwoman)

    pv # view status of pipes (bandwidth, etc.)

    marker # markdown editor
  ] ++ lib.optionals (!isAarch64) [
    dnsutils
  ];
}
