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
            merge.tool = "vimdiff";
            mergetool.prompt = true;
            difftool.prompt = false;
            diff.tool = "vimdiff";
            advice.addEmptyPathspec = false;
            diff.colorMoved = "default";
            log.showSignature = true;

            status.showStash = true;

            # Allows `git fetch upstream master:master` if current checkout branch is master
            # See `man git-config
            receive.denyCurrentBranch = "updateInstead";
          }
          (lib.mkIf config.programs.neovim.enable {
            mergetool.vimdiff = {
              cmd = "${config.programs.neovim.finalPackage}/bin/nvim -d $LOCAL $REMOTE $MERGE -c 'wincmd w' -c 'wincmd J'";
            };
          })
          (lib.mkIf (config.my.identity.gpgSigningKey != null) {
            tag.gpgSign = true;
            user.signingKey = config.my.identity.gpgSigningKey;
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
          # Convenient aliases for committing
          cm = "commit --verbose";
          cma = "${cm} --amend";
          cmar = "${cma} --reuse-message=HEAD";
          # Yeah....
          cmare = "${cmar} --edit";
          # Uhhhhhhh... nice
          cmard = "${cmar} --date=format:relative:now";
          cmarde = "${cmard} --edit";
          # Pretty graph
          graph = "! git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
          # Shows the latest commit with more detail
          latest = "show HEAD --summary";
          # Prints all aliases
          aliases = "! git config --get-regexp '^alias\\.' | sed -e 's/^alias\\.//' -e 's/\\ /\\ =\\ /' | grep -v '^aliases' | sort";
          # Quick view of all recents commits for stand-ups
          oneline = "log --pretty=oneline";
          activity = "! git for-each-ref --sort=-committerdate refs/heads/ "
                    + "--format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - "
                    + "%(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - "
                    + "%(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'";

          squash-all = ''!f(){ git reset $(git commit-tree HEAD^{tree} -m "''${1:-A new start}");};f'';
        };

        delta.enable = true;
        delta.options = {
          line-numbers = true;
          side-by-side = true;
          whitespace-error-style = "22 reverse";
          syntax-theme = "ansi-dark";
        };
      };
    }
  ];
}
