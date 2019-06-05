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
  # Tell pppd to run in the foreground and assign a pty instead of a tty
  # We force ssh to use the askpass program specified
  sudo /usr/sbin/pppd nodetach noauth silent nodeflate pty "
      /usr/bin/env DISPLAY=:0 SSH_ASKPASS=/usr/lib/ssh/gnome-ssh-askpass2 \
      /usr/bin/setsid \
      /usr/bin/ssh -i '/home/nicolas/.ssh/automation' root@dozer.qt.rs /usr/sbin/pppd nodetach notty noauth" \
    ipparam vpn '10.11.11.1:10.11.11.2' &
  # Route the wireguard stuff through there
  sudo ip route add 10.10.10.0/24 via 10.11.11.1
  # Route my home LAN through there
  sudo ip route add 192.168.0.0/24 via 10.11.11.1
  fg
  ;;
"down")
  sudo kill -9 $(ps -ax | awk '/pppd/ && !/vim/ { print $1 }')
  sudo pkill "$(basename $0)"
  ;;
*)
  echo "$0: no specified action"
  exit 1
  ;;
esac
