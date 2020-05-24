#!/bin/sh

# UNUSED
#!/usr/bin/env nix-shell
#!nix-shell -p wofi wl-clipboard coreutils

tac "$1" | wofi --dmenu --lines 5 | wl-copy -n

