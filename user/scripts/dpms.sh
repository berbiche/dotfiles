#!/usr/bin/env bash
set -o pipefail

swaymsg -t get_outputs |
  jq -r '.[] | select(.active==true) | [.name, .make, .model] | @tsv' |
  fzf --exit-0 --multi --reverse --prompt='Toggle DPMS for display: ' |
  awk '{print $1}' |
  xargs -I{} -r swaymsg output {} dpms toggle
