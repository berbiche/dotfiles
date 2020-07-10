#!/bin/sh

main() {
  selected_workspace=$(get_workspaces | menu | cut -d':' -f1 | tr -d \")

  if [[ ! -z "$selected_workspace" ]]; then
    swaymsg workspace number "$selected_workspace"
  fi
}

get_workspaces() {
  swaymsg -t get_workspaces | jq -r '.[] .name'
}

menu() {
  wofi -dim -w 1 -p 'workspace' -l 0 -W '30%'
}

main

