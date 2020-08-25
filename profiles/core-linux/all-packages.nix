{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget curl aria
    lsof
    nmap traceroute telnet tcpdump whois dnsutils mtr
    git rsync
    exa fd fzf rofi ripgrep hexyl tree bc bat
    htop ctop ytop
    neovim evince alacritty thunderbird libreoffice kitty
    docker-compose
  ];
}
