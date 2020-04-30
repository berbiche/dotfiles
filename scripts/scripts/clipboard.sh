#!/bin/sh

tac "$1" | wofi --dmenu --lines 5 | wl-copy -n

