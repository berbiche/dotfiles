#!/bin/sh
## Sway-idle configuration
# This will lock your screen after 300 seconds (5 minutes) of inactivity,
# then turn off your displays after another 600 seconds (15 minutes total), and
# turn your screens back on when resumed. It will also lock your screen before
# your computer goes to sleep.
#set -x

swaylock=`command -v swaylock`
swayidle=`command -v swayidle`
swaymsg=`command -v swaymsg`

$swayidle -w \
    timeout 300 "$swaylock -f" \
    timeout 600 "$swaymsg 'output * dpms off'" \
    resume "$swaymsg 'output * dpms on'" \
    before-sleep "$swaylock -f"
