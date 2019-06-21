#!/bin/bash
# This scripts creates a tunnel between my computer and my VPS
# using pppd through an SSH connection.
# My school seems to be blocking my simple wireguard configuration.
if [[ $EUID -ne 0 ]]; then
  echo "Superuser required to use /usr/sbin/pppd"
  exit 1
fi

case $1 in
"up")
  USER_HOME=$(getent passwd ${SUDO_USER} | cut -d: -f6)

  # Tell pppd to run in the foreground and assign a pty instead of a tty
  # And open a pppd on the remote end
  # We force ssh to use the askpass program specified
  # <<unreleated note, but does $USER always work when used with SUDO?>>
  sudo /usr/sbin/pppd nodetach noauth silent nodeflate pty "
      /usr/bin/sudo -u $SUDO_USER \
      /usr/bin/ssh -i '$USER_HOME/.ssh/automation' root@dozer.qt.rs /usr/sbin/pppd nodetach notty noauth" \
    ipparam vpn '10.11.11.1:10.11.11.2'
          #/usr/bin/env DISPLAY=:0 SSH_ASKPASS=/usr/lib/ssh/gnome-ssh-askpass2 \
      #/usr/bin/setsid \
  ;;
"down")
  process=$(ps -ax | awk '/pppd/ && !/vim/ { print $1 }')
  if [[ ! -z process ]]; then
    sudo kill -9 $process
  fi
  sudo pkill "$(basename $0)"
  ;;
*)
  echo "$0: no specified action"
  exit 1
  ;;
esac
