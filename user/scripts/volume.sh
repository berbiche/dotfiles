#!/bin/sh
case "$1" in
  increase)
    pamixer --unmute
    pamixer --increase 5
    volnoti-show "$(pamixer --get-volume)"
    ;;
  decrease)
    pamixer --unmute
    pamixer --decrease 5
    volnoti-show "$(pamixer --get-volume)"
    ;;
  toggle-mute)
    pamixer -t
    if pamixer --get-mute; then
      volnoti-show -m
    else
      volnoti-show "$(pamixer --get-volume)"
    fi
    ;;
  mic-mute)
    pactl set-source-mute '@DEFAULT_SOURCE@' toggle
    file="${TEMP:-${XDG_RUNTIME_DIR:-/}/tmp}/volume-sh"-LOCK
    touch "$file"
    exec 100>"$file"
    exec flock -F -E 0 -nx 100 /bin/sh -c 'eww open microphone; sleep 5; eww close microphone'
    ;;
  *)
    echo "Usage: $0 {increase|decrease|toggle-mute|mic-mute}"
    exit 1
esac
