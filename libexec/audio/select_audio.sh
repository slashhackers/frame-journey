#!/bin/bash

# select_audio.sh
# Selects an audio track based on explicit index, user prompt, or auto-selection.

# Arguments:
# $1: INPUT_FILE (video file path)
# $2: Space-separated string of AUDIO_STREAM_INFO (e.g., "0,eng 1,hin")
# $3: EXPLICIT_AUDIO_INDEX (optional, explicit index provided by user)

INPUT_FILE="$1"
AUDIO_STREAMS_RAW="$2"
EXPLICIT_AUDIO_INDEX="$3"

# Convert space-separated stream info into a bash array for easier processing
AUDIO_STREAMS=()
while IFS= read -r -d ' ' stream_info_item; do
  if [ -n "$stream_info_item" ]; then
    AUDIO_STREAMS+=("$stream_info_item")
  fi
done <<< "$AUDIO_STREAMS_RAW " # Add a space at the end to ensure the last item is read

# --- Main Logic ---

# 1. Handle explicit audio index provided by the user
if [ -n "$EXPLICIT_AUDIO_INDEX" ]; then
  # Validate explicit index (check if it exists in the streams)
  FOUND_EXPLICIT=false
  for STREAM_INFO in "${AUDIO_STREAMS[@]}"; do
    IFS=',' read -r STREAM_INDEX LANGUAGE_TAG <<< "$STREAM_INFO"
    if [ "$STREAM_INDEX" = "$EXPLICIT_AUDIO_INDEX" ]; then
      echo "$EXPLICIT_AUDIO_INDEX"
      exit 0 # Found and selected explicit index
    fi
  done
  # If not found, exit with error
  echo "Error: Explicit audio track index '$EXPLICIT_AUDIO_INDEX' not found in '$INPUT_FILE'." >&2
  exit 1
fi

# 2. Handle single or multiple audio streams (default to the first one)
if [ "${#AUDIO_STREAMS[@]}" -ge 1 ]; then
  IFS=',' read -r STREAM_INDEX LANGUAGE_TAG <<< "${AUDIO_STREAMS[0]}"
  echo "$STREAM_INDEX"
  exit 0 # Auto-selected the first available track
fi

# Fallback: No audio streams found or unexpected scenario
echo "Error: No audio streams found in '$INPUT_FILE' or could not determine selection." >&2
exit 1