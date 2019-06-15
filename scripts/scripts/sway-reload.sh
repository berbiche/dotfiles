#!/bin/bash
INTEGRATED_PANEL='eDP-1'

OUTPUTS=$(swaymsg -t get_outputs | jq 'map({active, name, make, model, serial})')
INTEGRATED_PANEL_STATE=$(echo $OUTPUTS |
  jq ".[] | select(.name == \"$INTEGRATED_PANEL\") | if .active then \"enable\" else \"disable\" end")
MORE_THAN_ONE_OUTPUT=$(echo $OUTPUTS | jq 'length > 0')

# Command to reload sway
COMMAND="swaymsg reload"

# Reload the config
NOTIFICATION=$(notify-send.sh --print-id "Reloading sway...")
eval $COMMAND

# Force sleep, because swaymsg cannot be made to block
sleep 5

# Now restore the integrated_panel state
COMMAND="swaymsg 'output $INTEGRATED_PANEL %s'"

# Deactive the integrated display if necessary
if [[ $MORE_THAN_ONE_OUTPUT == "false" ]]; then
  COMMAND=$(printf "$COMMAND" "enable")
else
  COMMAND=$(printf "$COMMAND" "$INTEGRATED_PANEL_STATE")
fi

eval $COMMAND

notify-send.sh --replace=$NOTIFICATION --expire-time=5000 "Sway done reloading"
