#!/bin/sh
ip a show to 192.168.0.0/16 | grep -v docker | grep -oP 'inet ([0-9\.]*)(?=/)' | cut -d' ' -f2
