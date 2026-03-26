#!/bin/bash
HEIGHT="$1"
[ "$HEIGHT" -ge 1080 ] && echo 1080
[ "$HEIGHT" -ge 720 ] && echo 720
[ "$HEIGHT" -ge 480 ] && echo 480
echo 360 # Always provide 360p as the baseline quality
