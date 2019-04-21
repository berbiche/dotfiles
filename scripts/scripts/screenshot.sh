#!/bin/bash

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
    -h|--help)
      echo "Accepted options are: 'selection', 'screen'"
      ;&
    *)
      echo 'no screenshot option selected' >&2
      exit 1
      ;;
  esac
}

create_dir() {
  mkdir -p $(dirname "$output_file")
}

print_selection() {
  create_dir
  grim -g "$(slurp)" "$output_file"
  notify-send "Screenshot: " ""
}

print_active_screen() {
  create_dir
  grim -o $(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name') "$output_file"
}

print_everything() {
  create_dir
  grim -c "$output_file"
}

main "$1"

