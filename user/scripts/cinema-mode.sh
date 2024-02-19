#!/bin/sh
#swaymsg output
PMODEL='BenQ EW3270U'
PSERIAL='74J08749019'

output=$(swaymsg -t get_outputs | jq '.[] | select((.model == "'"$PMODEL"'") and (.serial == "'"$PSERIAL"'")) | .name')

if [ "$1" = "on" ]; then
  if [ -n "$output" ]; then
    swaymsg -t get_outputs | jq '.[] | select(.name != '"$output"' and .active) | .name' | \
      xargs -r -I {} swaymsg -- output "{}" dpms off
  fi
elif [ "$1" = "off" ]; then
  swaymsg -- output \* dpms on
else
  echo 'Specify either "on" or "off"'
fi
