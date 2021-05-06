#!/bin/sh
echo Line count for folder "$1"
fd . $1 -H --exclude='*.desktop*' --exclude=.git -t f -x wc -l |
  awk 'BEGIN { count=0; } { print $0; count += $1; } END{ print "total line count is: " count; }'
