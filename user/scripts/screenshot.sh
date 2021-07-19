#!/usr/bin/env bash

usage="\
Usage:
  $(basename "$0") [OPTION...] {selection,screen,everything} - take a screenshot under Wayland

  -?|--help  show this help text

Where:
  selection   take a screenshot of a range to be selected
  window      take a screenshot of the currently focused window
  screen      take a screenshot of the active output
  everything  take a screenshot of the entire desktop \
"

output_file="$(xdg-user-dir SCREENSHOTS)/$(date +'%Y')/$(date +'%m')/$(date +'%Y-%m-%d-%H.%M.%S').png"

slurp="command slurp -d -s '#ff00001a' -c '#ff0000'"
select_window="$(dirname "$0")/sway_select_window_geometry.sh"


main() {
  case "$1" in
    selection)
      print_selection
      ;;
    window)
      print_window
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
  notify-send.sh --app-name=screenshot-tool \
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
  eval "$slurp" | grim -g- "$output_file"
}

print_window() {
  create_dir
  local window=`$select_window`
  grim -g "$window" "$output_file"
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

