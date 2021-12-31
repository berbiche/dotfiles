{ config, lib, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "$nix_shell"
        # "$username:$hostname "
        "$hostname "
        "$directory"
        # "$kubernetes"
        "$git_branch"
        "$git_status"
        # "$git_commit"
        #"$git_status"
        "$git_state"
        # "$hg_branch"
        # "$docker_context"
        # "$package"
        # "dotnet"
        # "$elixir"
        # "elm"
        # "$erlang"
        # "$golang"
        # "$haskell"
        # "$java"
        # "julia"
        # "$nodejs"
        # "ocaml"
        # "php"
        # "purescript"
        # "$python"
        # "ruby"
        # "$rust"
        # "$terraform"
        # "zig"
        # "conda"
        # "memory_usage"
        # "aws"
        # "gcloud"
        # "env_var"
        # "crystal"
        "$cmd_duration"
        # "custom"
        # "$line_break"
        "$jobs"
        # "$directory"
        # "$time"
        "$status"
        "$character"
      ];

      character = {
        error_symbol = ''[\$](bold red)'';
        success_symbol = ''[\$](bold green)'';
      };

      cmd_duration = {
        min_time = 5000;
        show_notifications = false;
        format = ''[$duration]($style) '';
      };

      directory = {
        truncation_length = 1;
        truncate_to_repo = false;
        read_only = "";
        fish_style_pwd_dir_length = 1;
      };

      git_branch = {
        symbol = "";
        only_attached = true;
        truncation_length = 12;
        format = "([$symbol$branch]($style) )";
      };

      git_status = {
        format = "([\\[$conflicted$deleted$modified$untracked$ahead_behind\\]]($style) )";
        untracked = "$count?";
        modified = "$count!";
        deleted = "$count✘";
      };

      hostname = {
        ssh_only = true;
        format = "[$hostname]($style)";
      };

      line_break.disabled = false;

      nix_shell = {
        # impure_msg = "";
        # pure_msg = "";
        # format = "via [$symbol$state(\\($name\\))]($style)";
        symbol = "❄️";
        # format = "[\\($symbol shell\\)]($style) ";
        format = "[\\($symbol ($name)\\)]($style) ";
      };

      status = {
        disabled = false;
        symbol = "";
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
}
