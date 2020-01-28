#!/usr/bin/env bash
case "$1" in
  increase)
    pamixer --unmute
    pamixer --increase 5
    volnoti-show $(pamixer --get-volume)
    ;;
  decrease)
    pamixer --unmute
    pamixer --decrease 5
    volnoti-show $(pamixer --get-volume)
    ;;
  toggle-mute)
    pamixer -t
    pamixer --get-mute && volnoti-show -m || volnoti-show `pamixer --get-volume`
    ;;
  mic-mute)
    pacmd list-sources | \
      awk '/\* index:/ {print $3}' | \
      xargs -I{} pactl set-source-mute {} toggle
    ;;
esac

