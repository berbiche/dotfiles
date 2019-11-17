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
esac

