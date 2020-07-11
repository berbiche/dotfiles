#!/usr/bin/env bash

class=$(playerctl metadata --player=spotify --format '{{lc(status)}}')
icon=""

if [[ $class =~ paused|playing ]]; then
  info=$(playerctl metadata --player=spotify --format '{{artist}} - {{title}}')
  if [[ ${#info} > 40 ]]; then
    info=$(echo $info | cut -c1-40)"..."
  fi
  text="$info [$class] $icon"
elif [[ $class == "stopped" ]]; then
  text=""
fi

echo -e "{\"text\":\""$text"\", \"class\":\""$class"\"}"
