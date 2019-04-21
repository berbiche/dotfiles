#!/bin/sh
# Wallpaper downloader using unsplash API
output_folder="$(xdg-user-dir PICTURES)/wallpaper"

url () {
  echo "https://source.unsplash.com/featured/$1/?nature,water"
}

for resolution in '3840x2160' '1920x1080' '1080x1920'; do
  wget -qO "$output_folder/$resolution.png" "$(url "$resolution")"
done
