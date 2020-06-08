#!/bin/sh
# Wallpaper downloader using unsplash API
output_folder="$(xdg-user-dir PICTURES)/wallpaper"

get_url () {
  echo "https://source.unsplash.com/featured/$1/?nature,water"
}

for resolution in '3840x2160' '1920x1080' '1080x1920'; do
  url=$(get_url "$resolution")
  output="$output_folder/$resolution.png"
  echo "fetching resolution $resolution from $url to file $output"
  wget -qO "$output" "$url"
done
