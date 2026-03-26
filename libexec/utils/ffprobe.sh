#!/bin/bash
INPUT="$1"
HEIGHT=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$INPUT")
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$INPUT")
# Extract index and language tag for each audio stream, format as "index,language_tag"
AUDIO_STREAMS=$(ffprobe -v error -select_streams a -show_entries stream=index:stream_tags=language -of default=noprint_wrappers=1 "$INPUT" | \
                 grep -E 'index=|TAG:language=' | \
                 sed -e 's/index=//g' -e 's/TAG:language=//g' | \
                 paste -d',' - - | \
                 tr '\n' ' ')
echo "$HEIGHT|$DURATION|$AUDIO_STREAMS"
