{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    wget curl aria
    
    colordiff
    
    git rsync
    
    exa fd fzf rofi ripgrep tree bc bat
    
    htop gotop ctop ytop
    
    lsof
    
    nmap
    parted
    ranger stow
    
    traceroute telnet tcpdump whois dnsutils mtr
        
    neovim evince alacritty thunderbird libreoffice kitty
    latest.firefox-nightly-bin
    
    docker-compose
  ];
}
