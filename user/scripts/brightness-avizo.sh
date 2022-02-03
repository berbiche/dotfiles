#!/bin/sh
current="$(cut -d, -f4 | tr -d '%')"
scaled="$(echo "scale=2; $current / 100.0" | bc)"
image=""
if [ "$current" -lt "34" ]; then
  image="brightness_low"
elif [ "$current" -lt "67" ]; then
  image="brightness_medium"
else
  image="brightness_high"
fi
avizo-client --image-resource="$image" --progress="$scaled"
