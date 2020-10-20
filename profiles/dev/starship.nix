{ config, lib, pkgs, ... }:

{
  my.home = { ... }: {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        add_newline = false;
        format = lib.concatStrings [
          "$username@$hostname"
          # "$kubernetes"
          "$git_branch"
          "$git_commit"
          "$git_state"
          "$git_status"
          # "$hg_branch"
          "$docker_context"
          "$package"
          # "dotnet"
          "$elixir"
          # "elm"
          "$erlang"
          "$golang"
          "$haskell"
          "$java"
          # "julia"
          "$nodejs"
          # "ocaml"
          # "php"
          # "purescript"
          "$python"
          # "ruby"
          "$rust"
          "$terraform"
          # "zig"
          "$nix_shell"
          # "conda"
          # "memory_usage"
          # "aws"
          # "gcloud"
          # "env_var"
          # "crystal"
          "$cmd_duration"
          # "custom"
          "$line_break"
          "$jobs"
          "$directory"
          "$time"
          "$status"
          "$character"
        ];

        character = {
          error_symbol = ''[\$](bold red)'';
          success_symbol = ''[\$](bold green)'';
        };

        cmd_duration.disable = true;

        directory = {
          truncation_length = 1;
          truncate_to_repo = false;
          fish_style_pwd_dir_length = 1;
        };

        hostname = {
          ssh_only = false;
          format = "<[$hostname]($style)> ";
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
          time_format = "%H:%M";
          format = "[\\[$time\\]]($style) ";
        };

        username = {
          disabled = false;
          show_always = true;
          format = "[$user]($style)";
        };
      };
    };
  };
}
