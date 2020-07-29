{ config, lib, pkgs, ... }:

{
  home.packages = [ pkgs.neofetch ];

  xdg.configFile."neofetch/config.conf".text = ''
    # See this wiki page for more info:
    # https://github.com/dylanaraps/neofetch/wiki/Customizing-Info
    print_info() {
        info title
        info underline

        info "OS" distro
        info "Host" model
        info "Kernel" kernel
        info "Uptime" uptime
        info "Packages" packages
        info "Shell" shell
        info "Resolution" resolution
        info "DE" de
        info "WM" wm
        info "WM Theme" wm_theme
        info "Theme" theme
        info "Icons" icons
        info "Terminal" term
        info "Terminal Font" term_font
        info "CPU" cpu
        info "GPU" gpu
        info "Memory" memory

        # info "GPU Driver" gpu_driver  # Linux/macOS only
        # info "CPU Usage" cpu_usage
        # info "Disk" disk
        info "Battery" battery
        info "Font" font
        info "Song" song
        # [[ $player ]] && prin "Music Player" "$player"
        # info "Local IP" local_ip
        # info "Public IP" public_ip
        # info "Users" users
        info "Locale" locale  # This only works on glibc systems.

        info cols
    }


    uptime_shorthand="off"
    memory_percent="on"
    package_managers="on"
    shell_path="off"
    speed_shorthand="on"
    cpu_temp="C"
    refresh_rate="on"
    separator=" ->"
    block_range=(0 15)
    memory_display="infobar"
    battery_display="barinfo"
    thumbnail_dir="${config.xdg.cacheHome}/thumbnails/neofetch"
'';
}
