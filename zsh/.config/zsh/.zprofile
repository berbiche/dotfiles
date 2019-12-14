# Launch sway on tty1 if no other sway instances are running
if [[ -z $DISPLAY ]] && [[ -z $SWAYSOCK ]] && [[ $(tty) = /dev/tty2 ]]; then
  #DATE=`date --iso-8601`
  #touch "$HOME/.cache/sway/log-$DATE"
  #echo "Launching sway" >> "$HOME/.cache/sway/log-$DATE"
  #exec sway --config ${XDG_CONFIG_HOME:-$HOME/.config}/sway/config -d >>"$HOME/.cache/sway/log-$DATE"
  exec sway --config ${XDG_CONFIG_HOME:-$HOME/.config}/sway/config
  #systemctl --user import-environment
  #exec systemctl --wait --user start sway.service
fi

