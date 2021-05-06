#!/bin/sh

wl-paste -w /bin/sh -c '
  echo $(</dev/stdin) >> "${XDG_CACHE_HOME}/clipboard"
  # echo >> %C/clipboard
  gawk -i inplace '"'!seen[\$0]++'"' "${XDG_CACHE_HOME}/clipboard"
'
