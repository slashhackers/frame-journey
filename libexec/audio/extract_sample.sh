#!/bin/bash
INPUT="$1"
STREAM="$2"
OUT="/tmp/audio_$STREAM.wav"
ffmpeg -y -i "$INPUT" -map 0:"$STREAM" -t 60 -ar 16000 -ac 1 "$OUT" >/dev/null 2>&1
echo "$OUT"
