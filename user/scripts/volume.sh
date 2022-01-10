#!/bin/sh

_display_volume() {
  current="$(pamixer --get-volume)"
  scaled="$(echo "scale=2; $current / 100.0" | bc)"
  image=""
  if [ "$current" -lt "34" ]; then
    image="volume_low"
  elif [ "$current" -lt "67" ]; then
    image="volume_medium"
  else
    image="volume_high"
  fi
  avizo-client --image-resource="$image" --progress="$scaled"
}

case "$1" in
  increase)
    pamixer --unmute
    pamixer --increase 5
    # volnoti-show "$(pamixer --get-volume)"
    _display_volume
    ;;
  decrease)
    pamixer --unmute
    pamixer --decrease 5
    # volnoti-show "$(pamixer --get-volume)"
    _display_volume
    ;;
  toggle-mute)
    pamixer -t
    if pamixer --get-mute; then
      #volnoti-show -m
      avizo-client --image-resource="volume_muted" --progress="0"
    else
      #volnoti-show "$(pamixer --get-volume)"
      _display_volume
    fi
    ;;
  mic-mute)
    pactl set-source-mute '@DEFAULT_SOURCE@' toggle
    if pamixer --source '@DEFAULT_SOURCE@' --get-mute; then
      avizo-client --image-resource="mic_muted"
    else
      avizo-client --image-resource="mic_unmuted"
    fi
    ;;
  *)
    echo "Usage: $0 {increase|decrease|toggle-mute|mic-mute}"
    exit 1
esac
