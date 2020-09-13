{ config, lib, pkgs, ... }:

{
  home-manager.users.${config.my.username} = { ... }: {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        add_newline = true;
        prompt_order = [
          "username"
          "hostname"
          "kubernetes"
          "git_branch"
          "git_commit"
          "git_state"
          "git_status"
          "hg_branch"
          "docker_context"
          "package"
          "dotnet"
          "elixir"
          "elm"
          "erlang"
          "golang"
          "haskell"
          "java"
          "julia"
          "nodejs"
          "ocaml"
          "php"
          "purescript"
          "python"
          "ruby"
          "rust"
          "terraform"
          "zig"
          "nix_shell"
          "conda"
          "memory_usage"
          "aws"
          "env_var"
          "crystal"
          "cmd_duration"
          "custom"
          "line_break"
          "jobs"
          "battery"
          "directory"
          "time"
          "character"
        ];

        character.symbol = "$";

        cmd_duration.disable = true;

        directory = {
          prefix = "";
          truncation_length = 1;
          truncate_to_repo = false;
          fish_style_pwd_dir_length = 1;
        };

        hostname = {
          ssh_only = false;
          prefix = "<";
          suffix = ">";
        };

        line_break.disabled = false;

        nix_shell = {
          use_name = false;
          impure_msg = "";
          pure_msg = "";
          symbol = "❄️";
        };

        time = {
          disabled = false;
          format = "%H:%M";
          prefix = "";
        };

        username = {
          disabled = false;
          show_always = true;
        };
      };
    };
  };
}
