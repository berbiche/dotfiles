#!/bin/sh

# source: https://askubuntu.com/a/675132
nmcli --fields UUID,TIMESTAMP-REAL con show | \
  grep never | \
  awk '{print $1}' | \
  while read -r line; do
    nmcli con delete uuid "$line"
  done
