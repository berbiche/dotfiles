#!/bin/sh
# Sway-idle configuration
/usr/bin/swayidle -w \
        timeout 300 'swaylock -f' \
        timeout 600 'swaymsg "output * dpms off"' \
                resume 'swaymsg "output * dpms on"' \
        before-sleep 'swaylock -f'
