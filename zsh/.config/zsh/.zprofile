# Launch sway on tty1 if no other sway instances are running
if [[ -z $DISPLAY ]] && [[ -z $SWAYSOCK ]] && [[ $(tty) = /dev/tty2 ]]; then
  exec sway --config ${XDG_CONFIG_HOME:-$HOME/.config}/sway/config -d
  #systemctl --user import-environment
  #exec systemctl --wait --user start sway.service
fi

