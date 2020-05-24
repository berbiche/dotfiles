#!/usr/bin/env bash
set -o pipefail

# Moves the current workspace to the only other screen
# (fails if there is more than one active screen available)
swaymsg -t get_outputs |
    jq 'map(select(.active==true and .focused!=true) | .name) |
        if length > 1 then error("more than one display matches query")
        else .[]
        end' |
    xargs --no-run-if-empty swaymsg move workspace to
