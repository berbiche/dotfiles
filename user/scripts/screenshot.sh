#!/usr/bin/env bash

set -o pipefail

usage() {
  # Multiline Bashism
  echo >&2 "
Usage:
  $(basename "$0") [OPTION...] {everything,selection,screen,window}

  -?|--help  show this help text

where:
  selection   take a screenshot of a range to be selected
  window      take a screenshot of the currently focused window
  screen      take a screenshot of the active output
  everything  take a screenshot of the entire desktop\
"
}

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
      usage
      exit
      ;;
    *)
      usage
      exit 1
      ;;
  esac

  if [ $? -eq 0 ]; then
    notify
    copy_clipboard
  fi
}

# Flameshot version 11.0.0 has a regression where if the screenshot
# is cancelled it does not return an exit code > 0
_flameshot() {
  # Basically, this greps stderr for the string "aborted" and returns an unsuccesful
  # exit code if found. In all cases stdout is left untouched
  # which allows processing of stdout
  { flameshot "$@" --path "$output_file" 2>&1 1>&3 | {
      if grep -qs "aborted"; then
        echo "Screenshot cancelled"
        return 1;
      fi
    }
  } 3>&1
}

create_dir() {
  mkdir -m 0750 -p "$(dirname "$output_file")"
}

# $1: notification title
notify() {
  # Only show if last exit code is a success
  notify-send.sh --app-name=screenshot-tool \
    "Screenshot" "Saved to $output_file and copied to clipboard" \
    --default-action "feh --scale-down --auto-zoom --draw-filename '$output_file'"
}

copy_clipboard() {
  if [ ! -z "$WAYLAND_DISPLAY" ]; then
    wl-copy < "$output_file"
  else
    xclip -selection clipboard -t image/png -i "$output_file"
  fi
}

print_selection() {
  create_dir
  _flameshot gui

  # old code:
  # eval "$slurp" | grim -g- "$output_file"
}

print_window() {
  create_dir
  if [ ! -z "$WAYLAND_DISPLAY" ]; then
    local window=`$select_window`
    grim -g "$window" "$output_file"
  fi
}

print_active_screen() {
  create_dir
  # How does Qt and flameshot handle Wayland screen numbers?
  # Looking at the source code: https://github.com/flameshot-org/flameshot/blob/5ab76e233bfe6835649cc27fa9c68bc185a6b0b8/src/core/controller.cpp#L345-L363
  # it doesn't seem to support selecting a screen by it's name at this time
  _flameshot screen

  # old code:
  # local output=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')
  # grim -o $output "$output_file"
}

print_everything() {
  create_dir
  _flameshot full

  # old code:
  # grim -c "$output_file"
}

main "$1"

