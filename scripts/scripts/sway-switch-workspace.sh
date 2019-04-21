#!/bin/sh

main() {
  selected_workspace=$(get_workspaces | rofi_menu | cut -d':' -f1 | tr -d \")

  if [[ ! -z "$selected_workspace" ]]; then
    swaymsg workspace number "$selected_workspace"
  fi
}

get_workspaces() {
  swaymsg -t get_workspaces | jq -r '.[] .name'
}

rofi_menu() {
  rofi -dmenu -p 'workspace' -show-icons -i -no-custom -m -4 -location 0 -width 30
}

main

