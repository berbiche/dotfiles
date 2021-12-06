{ ... }:

{
  # Quickly jump to directories with `z something` or `z s`
  # Learns the most frequently used directories and allows you to jump to them
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };
}
