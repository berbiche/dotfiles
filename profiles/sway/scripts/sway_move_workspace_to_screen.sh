#!/usr/bin/env bash
set -o pipefail

# Select the screen to move the current workspace to
swaymsg -t get_outputs |
    jq -r '.[] | select(.active==true and .focused!=true) | [.name, .make, .model] | @tsv' |
    fzf --exit-0 --reverse --prompt='Move workspace to:' |
    awk '{print $1}' |
    xargs -r swaymsg move workspace to
