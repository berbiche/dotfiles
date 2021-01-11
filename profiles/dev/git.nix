{ config, ... }:

let
  cfg = config;
in
{
  my.home = { config, lib, pkgs, ... }: lib.mkMerge [
    (lib.mkIf (config.services.gnome-keyring.enable || cfg.services.gnome3.gnome-keyring.enable) {
      home.packages = [ pkgs.gnome3.seahorse ];
      programs.git.extraConfig.credential.helper = "gnome-keyring";
    })
    {
      programs.git = {
        enable = true;
        package = pkgs.gitFull;

        userName = config.my.identity.name;
        userEmail = config.my.identity.email;

        extraConfig = lib.mkMerge [
          {
            user.useConfigOnly = true;
            pull.ff = "only";
            push.default = "current";
            mergetool.prompt = true;
            difftool.prompt = false;
            advice.addEmptyPathspec = false;
            diff.colorMoved = "default";
            log.showSignature = false;

            status.showStash = true;

            # Allows `git fetch upstream master:master` if current checkout branch is master
            # See `man git-config
            receive.denyCurrentBranch = "updateInstead";
          }
          (lib.mkIf config.programs.neovim.enable {
            mergetool.nvimdiff = {
              cmd = "${config.programs.neovim.finalPackage}/bin/nvim -d $LOCAL $REMOTE $MERGE -c 'wincmd w' -c 'wincmd J'";
            };
            merge.guitool = "nvimdiff";
            merge.tool = "nvimdiff";
          })
          (lib.mkIf (config.my.identity.gpgSigningKey != null) {
            commit.gpgSign = true;
            tag.gpgSign = true;
            user.signingKey = config.my.identity.gpgSigningKey;
            # https://people.kernel.org/monsieuricon/signed-git-pushes
            # Signs pushes to prevent replay attacks
            push.gpgSign = "if-asked";
          })
        ];

        aliases = rec {
          b = "branch -vv";
          d = "diff";
          s = "show";
          f = "fetch --verbose";
          u = "reset HEAD";
          bn = "checkout -b";
          ch = "checkout";
          dc = "diff --cached";
          st = "status";
          # stash list pretty https://stackoverflow.com/a/38826108
          sl = lib.concatStrings [
            "stash list --pretty=format:'"
              "%C(red)%h%C(reset) - %C(dim yellow)(%C(bold magenta)%gd%C(dim yellow))" # left part
              "%C(reset) %<(70,trunc)%s %C(green)(%ci) %C(bold blue)<%an>%C(reset)" # right part
            "'"
          ];
          # Convenient aliases for committing
          cm = "commit --verbose";
          cma = "${cm} --amend";
          cmar = "${cma} --reuse-message=HEAD";
          cmare = "${cmar} --edit";
          # I don't remember why I used 'format:relative:now' instead of 'now'
          # I think the 'format:' was introduced before 'now'? https://stackoverflow.com/a/19742762
          cmard = ''${cmar} --date="''${GIT_COMMITTER_DATE:-"format:relative:now}"'';
          cmarde = "${cmard} --edit";
          # Pretty graph
          graph = lib.concatStrings [
            "! git log --graph --pretty='"
              "%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset"
            "'"
          ];
          # Shows the latest commit with more detail
          latest = "show HEAD --summary";
          # Shows all commits since last fetched ORIG_HEAD
          # https://git.wiki.kernel.org/index.php/Aliases
          lc = "log ORIG_HEAD.. --stat --no-merges";
          # Prints all aliases
          aliases = toString [
            "! git config --get-regexp '^alias\\.'"
              "| sed -e 's/^alias\\.//' -e 's/\\ /\\ =\\ /'"
              "| grep -v '^aliases'"
              "| sort"
          ];
          # Prints one alias
          alias = "!f(){ git config --get --global alias.\"$1\"; }; f || echo 'alias not found'";
          # Quick view of all recents commits for stand-ups
          oneline = "log --pretty=oneline";
          activity = lib.concatStrings [
            "! git for-each-ref --sort=-committerdate refs/heads/ --format='"
              "%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - "
              "%(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - "
              "%(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'"
          ];
          # I think I used this once
          # https://stackoverflow.com/a/23486788
          # tldr: creates a new root starting from the last commit with an optional message
          #       this effectively "squashes" everything.
          # Most likely needs a force push
          squash-all = ''!f(){ git reset $(git commit-tree HEAD^{tree} -m "''${1:-A new start}");};f'';

          # Adds a new remote with the given Github handle and repo name
          # `git remote-github upstream nix-community/home-manager`
          remote-github = ''!f(){ git remote add "$1" git@github.com:"''${2%/*}"/"''${2#*/}".git; }; f'';
        };

        delta.enable = true;
        delta.options = {
          line-numbers = true;
          side-by-side = false;
          whitespace-error-style = "22 reverse";
          syntax-theme = "ansi-dark";
        };
      };
    }
  ];
}
