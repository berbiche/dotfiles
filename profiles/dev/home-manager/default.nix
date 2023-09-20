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

  profiles.dev.wakatime.enable = lib.mkDefault true;

  # Alias jq to the go version of the tool
  home.shellAliases."jq" = "gojq";
  home.packages = with pkgs; [
    coreutils # just to make sure I use the right tools on MacOS, not the BSD variants

    gojq # tool to extract data out from a json input (files, stdin, ...)
    fq # like jq but for any binary format
    yq-go # like jq for yaml
    fx # equivalent of piping json to `less` with the ability to minimize nodes

    # Programming
    gnumake # for the `make` program
    # Broken: 2023-05-22 because OpenSSL 1.1 is marked "unsecure"
    #powershell # for some rare one-off scripts and tests
    tig # navigate a git repository's log and commits in a TUI, provides sorting, filtering, etc.

    aria # curl/wget on steroid to download files using different protocols
    bandwhich # see which programs are using network
    bat # a better alternative to cat with syntax highlighting
    bc # terminal calculator though I prefer using a python repl or `python -c 'print(39**25)'`
    bottom # `btm` is an htop/gotop/... alternative
    ctop # shows running containers (supports docker, mock, runc)
    curl # make advanced http requests, fetch files, etc.
    dnsutils # dns lookups
    docker-compose # a nice wrapper for docker to manage multiple docker containers (for one-off projects)
    du-dust # du with a tree-like listing and usage graph
    eza # a better ls with colors, tree support (it has to evaluate the entire file tree unfortunately)
    fd # find with an easier syntax (though it doesn't replace find entirely)
    fzf # used in scripts as a fuzzy matcher for passed inputs as well as `kill -9 <tab><tab>` completion
    gitFull # contains extra stuff that I don't remember
    hexyl # binary viewer like xxd (kinda sucks though)
    htop # shows running processes with sorting or filtering
    # httpie # like curl/wget with a simpler cli interface
    hyperfine # benchmarking tool
    kubie # a better kubens
    lsof # shows information about opened files by processes, useful for debugging
    manix # lookup a nix function documentation or a NixOS/Home Manager option documentation
    mtr # interactive traceroute that updates continuously
    netcat-gnu # better than telnet
    nmap # scanner for CTF and my local network
    ouch # a generic compressor/decompressor tool
    procs # an alternative to ps to view all currently running processes (static view)
    ripgrep # grep with some nice defaults
    rsync # copy files localy and remotely
    sd # replace lines in files or lines in stdin without the "annoying" syntax of sed or awk
    socat # unix socket connections, etc.
    #spacer # inserts a space with timestamps when tailing program that output infrequently
    tcpdump # see packet flows on interfaces to debug stuff
    tokei # shows the number of lines of code in a folder for each language
    tree # file list tree
    wget # I prefer using curl but still useful for one-off things

    ispell # spellchecking

    github-cli # Quite useful actually

    googler # search Google from the command line and copy links

    # NixOS/nixpkgs stuff
    nixpkgs-review # review nixpkgs PR
    nix-update # quickly update a package

    # Global packages for some programming languages
    # I often open repls to test things
    # v Works well with my python alias to "ptipython"
    (python3.withPackages (ps: [ ps.ptpython ps.ipython ]))
    erlang
    rebar3

  ] ++ lib.optionals isLinux [
    nix-top # status of packages being built

    # Broken: 2021-07-10
    # pipr # interactive tool to write pipelines
    # bubblewrap # required by pipr

    # Broken: 2023-03-05
    ncdu # interactive du

    insomnia # GUI tool to test http APIs, alternative to postman and hoppscotch (formerly postwoman)

    pv # view status of pipes (bandwidth, etc.)

    marker # markdown editor
  ] ++ lib.optionals (!isAarch64) [
    iotop # see which processes/kernel tasks are using IO

    # onefetch's libresolv dependency does not build on aarch64
    onefetch # neofetch for a git repository : lines of code, repo, etc.
  ];
}
