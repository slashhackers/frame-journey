#!/bin/bash
HEIGHT="$1"
[ "$HEIGHT" -ge 1080 ] && echo 1080
[ "$HEIGHT" -ge 720 ] && echo 720
