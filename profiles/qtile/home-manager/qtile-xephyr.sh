#!/usr/bin/env nix-shell
#!nix-shell -p xorg.xorgserver qtile python3 -i bash

SCREEN_SIZE=${SCREEN_SIZE:-1920x1080}
XDISPLAY=${XDISPLAY:-:1}
LOG_LEVEL=${LOG_LEVEL:-INFO}
# APP=${APP:-$(python -c "from libqtile.utils import guess_terminal; print(guess_terminal())")}
APP=${APP:-alacritty}

Xephyr +extension RANDR -screen ${SCREEN_SIZE} ${XDISPLAY} -ac &
XEPHYR_PID=$!
(
  sleep 1
  env DISPLAY=${XDISPLAY} QTILE_XEPHYR=1 qtile start -c ~/dotfiles/profiles/qtile/home-manager/python/config.py -l ${LOG_LEVEL} $@ &
  QTILE_PID=$!
  env DISPLAY=${XDISPLAY} ${APP} &
  wait $QTILE_PID
  kill $XEPHYR_PID
)
