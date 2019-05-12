# Launch sway on tty1 if no other sway instances are running
if [[ -z $DISPLAY -a -z $SWAYSOCK ]] && [[ $(tty) = /dev/tty1 ]]; then
  exec sway
fi

