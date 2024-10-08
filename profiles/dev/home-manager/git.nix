moduleArgs@{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

  # Transforms a git alias into an attribute set to be reused by other aliases
  # and abuses the __toString property of attribute sets for the serialization
  # of the alias when converting to an INI
  # `toString (mkFunction "echo 1; \n echo 2" ]) == "!f(){ echo 1; ; echo 2; }; f"`
  mkFunction = x: let
    y = lib.concatStringsSep "; " (lib.splitString "\n" x);
  in {
    __toString = _: "!f(){ ${y}; }; f";
    unwrapped = y;
  };

  osConfig = moduleArgs.osConfig or { };
in
lib.mkMerge [
  (lib.mkIf (isLinux && (config.services.gnome-keyring.enable || osConfig.services.gnome.gnome-keyring.enable or false)) {
    home.packages = [ pkgs.gnome.seahorse ];
    programs.git.extraConfig.credential.helper = "gnome-keyring";
  })
  {
    home.packages = [ pkgs.git-absorb ];

    programs.git = {
      enable = true;
      package = pkgs.gitFull;

      userName = config.my.identity.name;
      userEmail = config.my.identity.email;

      extraConfig = lib.mkMerge [
        {
          core.eol = "lf";
          core.autocrlf = false;

          user.useConfigOnly = true;
          pull.ff = "only";
          push.default = "current";
          mergetool.prompt = false;
          difftool.prompt = false;
          advice.addEmptyPathspec = false;
          diff.colorMoved = "default";
          log.showSignature = false;
          init.defaultBranch = "master";
          status.showStash = true;

          # Allows `git fetch upstream master:master` if current checkout branch is master
          # See `man git-config
          receive.denyCurrentBranch = "updateInstead";
        }
        (lib.mkIf config.programs.neovim.enable {
          mergetool.nvimdiff = {
            cmd = "${config.programs.neovim.finalPackage}/bin/nvim -d \"$LOCAL\" \"$REMOTE\" \"$MERGE\" -c 'DiffviewOpen'";
          };
          difftool.nvimdiff = {
            cmd = "${config.programs.neovim.finalPackage}/bin/nvim -d \"$LOCAL\" \"$REMOTE\" -c 'DiffviewOpen'";
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
        (lib.mkIf isDarwin {
          # This is VERY VERY impure and needed to use ssh keys automatically loaded with MacOS' Keychain
          # https://github.com/NixOS/nixpkgs/issues/15686#issuecomment-865928923
          core.sshCommand = "/usr/bin/ssh";
        })
      ];

      ignores = [
        ".vagrant/"
        "~."
        ".DS_STORE"
        ".DS_Store"
        "*.swp"
        "kubeconfig"
        ".direnv/"
      ];

      includes = [
        {
          path = "~/dev/adgear/gitconfig"; 
          condition = "gitdir:~/dev/adgear/";
        }
      ];

      aliases = lib.mapAttrs (_n: toString) rec {
        a  = "add";
        an = "${a} --intent-to-add";
        aa = "${a} --all";
        au = "${a} --update";
        b = "branch -vv";
        bn = "checkout -b";
        ch = "checkout";
        cp = "cherry-pick";
        cpe = "cherry-pick --edit";
        cpc = "cherry-pick --continue";
        cpa = "cherry-pick --abort";
        d = "diff";
        dc = "diff --cached";
        f = "fetch --prune";
        fa = "${f} --all";
        fo = "${f} origin";
        fu = "${f} upstream";
        # Not sure how to correctly check if GIT_DIR and/or GIT_WORK_TREE are set...
        # so just assume that .git is always relative to this alias
        # This alias runs git commit with the content of the last COMMIT_EDITMSG
        # when for instance I enter the wrong password for my pgp key
        # The cleanup doesn't work correctly and the file changelog is committed as part of the commit.
        tabarnak = "commit --cleanup=strip -F .git/COMMIT_EDITMSG";

        # Copied from a coworker who probably copied it from here: https://stackoverflow.com/a/34467298
        lg = lg1;
        lg1 = "lg1-specific --all";
        lg2 = "lg2-specific --all";
        lg3 = "lg3-specific --all";
        lg1-specific = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'";
        lg2-specific = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'";
        lg3-specific = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset) %C(bold cyan)(committed: %cD)%C(reset) %C(auto)%d%C(reset)%n''          %C(white)%s%C(reset)%n''          %C(dim white)- %an <%ae> %C(reset) %C(dim white)(committer: %cn <%ce>)%C(reset)'";

        p = "pull --prune";
        pa = "${p} --autostash";
        pl = "${p} --rebase";
        pu = "${p} upstream";
        pum = "${pu} master:master";
        plum = "${pl} upstream master:master";
        pp = "push --prune";
        ppff = "${pp} --force-with-lease --force-if-includes";
        r  = "rebase";
        ra = "rebase --abort";
        rc = "rebase --continue";
        ri = "rebase -i";
        rh = "reset --hard";
        s = "show";
        st = "status";
        u = "reset HEAD";
        # Shows the latest commit with more detail
        latest = "show HEAD --summary";
        # Shows all commits since last fetched ORIG_HEAD
        # https://git.wiki.kernel.org/index.php/Aliases
        lc = "log ORIG_HEAD.. --stat --no-merges";
        # Shows all local commits ahead of FETCH_HEAD
        llc = "log FETCH_HEAD.. --stat --no-merges";
        # stash list pretty https://stackoverflow.com/a/38826108
        sl = lib.concatStrings [
          "stash list --pretty=format:'"
            "%C(red)%h%C(reset) - %C(dim yellow)(%C(bold magenta)%gd%C(dim yellow))" # left part
            "%C(reset) %<(70,trunc)%s %C(green)(%ci) %C(bold blue)<%an>%C(reset)" # right part
          "'"
        ];
        # Clone aliases
        cl = mkFunction ''
          if [ "$#" -eq 0 ]; then echo "expected a remote name but none was given"; exit 1; fi
          local origin="$1"; shift
          git clone --origin="$origin" "$@"'';
        clo = "${cl} origin";
        clu = "${cl} upstream";
        # Convenient aliases for committing
        cm = "commit --verbose";
        cma = "${cm} --amend";
        cmae = "${cma} --edit";
        cman = "${cma} --no-edit";
        cmar = "${cma} --reuse-message";
        # I don't remember why I used 'format:relative:now' instead of 'now'
        # I think the 'format:' was introduced before 'now'? https://stackoverflow.com/a/19742762
        cmard = mkFunction ''git ${cmar} "$@" --date="''${GIT_COMMITTER_DATE:-'format:relative:now'}"'';
        cmarde = mkFunction "${cmard.unwrapped} --edit";
        # Pretty graph
        graph = lib.concatStrings [
          "! git log --graph --pretty='"
            "%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset"
          "'"
        ];
        # Prints all aliases
        aliases = builtins.concatStringsSep " " [
          "! git config --get-regexp '^alias\\.'"
            "| sed -e 's/^alias\\.//' -e 's/\\ /\\ =\\ /'"
            "| grep -v '^aliases'"
            "| sort"
        ];
        # Prints one alias
        alias = mkFunction "git config --get alias.\"$1\" || echo 'alias not found'";
        # Quick view of all recents commits for stand-ups
        oneline = "! git --no-pager log --oneline -n 20";
        activity = lib.concatStrings [
          "! git for-each-ref --sort=-committerdate refs/heads/ --format='"
            "%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - "
            "%(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - "
            "%(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'"
        ];
        # I think I used this once
        # https://stackoverflow.com/a/23486788
        # tldr: creates a new root starting from the last commit with an optional message
        #       this effectively "squashes" everything with an optional message
        # Most likely needs a force push
        squash-all = mkFunction ''git reset $(git commit-tree HEAD^{tree} -m "''${1:-A new start}")'';

        # Adds a new remote with the given Github handle and repo name
        # `git remote-github upstream nix-community/home-manager`
        remote-github = mkFunction ''git remote add "$1" git@github.com:"''${2%/*}"/"''${2#*/}".git'';
        rgb = remote-github;
      };

      delta.enable = true;
      delta.options = {
        line-numbers = true;
        side-by-side = false;
        whitespace-error-style = "22 reverse";
        syntax-theme = "ansi";
      };
    };
  }
]
