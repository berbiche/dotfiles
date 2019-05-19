#!/bin/bash
INTEGRATED_PANEL='eDP-1'

OUTPUTS=$(swaymsg -t get_outputs | jq 'map({active, name, make, model, serial})')
INTEGRATED_PANEL_STATE=$(echo $OUTPUTS |
  jq ".[] | select(.name == \"$INTEGRATED_PANEL\") | if .active then \"enabled\" else \"disabled\" end")
MORE_THAN_ONE_OUTPUT=$(echo $OUTPUTS | jq 'length > 0')

# Command to reload sway
COMMAND="swaymsg 'reload; output $INTEGRATED_PANEL %s'"

# Deactive the integrated display if necessary
if [[ $MORE_THAN_ONE_OUTPUT == "false" ]]; then
  COMMAND=$(printf $COMMAND "enabled")
else
  COMMAND=$(printf $COMMAND "$INTEGRATED_PANEL_STATE")
fi

# Reload the config
eval $COMMAND
