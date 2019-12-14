#!/usr/bin/env bash

usage="\
Usage:
  $(basename "$0") [OPTION...] {selection,screen,everything} - take a screenshot under Wayland

  -?|--help  show this help text

Where:
  selection   take a screenshot of a range to be selected
  screen      take a screenshot of the active output
  everything  take a screenshot of the entire desktop \
"

output_file="$(xdg-user-dir PICTURES)/screenshots/$(date +'%Y')/$(date +'%m')/$(date +'%Y-%m-%d-%H.%M.%S').png"



main() {
  case "$1" in
    selection)
      print_selection
      ;;
    screen)
      print_active_screen
      ;;
    everything)
      print_everything
      ;;
    -?|--help)
      echo "$usage" >&2
      exit
      ;;
    *)
      echo "$usage" >&2
      exit 1
      ;;
  esac

  if [ $? -eq 0 ]; then
    post_process
  fi
}

create_dir() {
  mkdir -p $(dirname "$output_file")
}

# $1: notification title
notify() {
  # Only show if last exit code is a success
  notify-send.sh --icon=mail-unread --app-name=screenshot-tool \
    "Screenshot" "Saved to $output_file and copied to clipboard" \
    --default-action "feh --scale-down --auto-zoom --draw-filename '$output_file'"
}

copy_clipboard() {
  wl-copy < "$output_file"
}

post_process() {
  notify
  copy_clipboard
}

print_selection() {
  create_dir
  grim -g "$(slurp)" "$output_file"
}

print_active_screen() {
  create_dir
  local output=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')
  grim -o $output "$output_file"
}

print_everything() {
  create_dir
  grim -c "$output_file"
}

main "$1"

