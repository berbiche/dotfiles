#!/bin/sh
echo Line count for folder "$0"
fd . $0 -H --exclude='*.desktop*' --exclude=.git -t f -x wc -l |
  awk 'BEGIN { count=0; } { print $0; count += $1; } END{ print "total line count is: " count; }'
