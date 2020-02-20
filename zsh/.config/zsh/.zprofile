# Better history in ZSH
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
unsetopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY



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
