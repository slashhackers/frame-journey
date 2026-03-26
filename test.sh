#!/bin/bash

# Initialize variables
INPUT_FILE=""
SELECTED_RESOLUTION=""
TRIM_START=""
TRIM_DURATION="" # Changed from TRIM_END

# Parse arguments for test.sh
while getopts "r:" opt; do
  case $opt in
    r)
      SELECTED_RESOLUTION="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

INPUT_FILE="$1"

# Check if an input file is provided
if [ -z "$INPUT_FILE" ]; then
    echo "Usage: $0 [-r <resolution>] <input_video_file>"
    exit 1
fi

# Check if the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found."
    exit 1
fi

echo "Processing input file: '$INPUT_FILE'"

# Get video duration using ffprobe.sh
FFPROBE_OUTPUT=$(./utils/ffprobe.sh "$INPUT_FILE")
IFS='|' read -r HEIGHT DURATION_STR AUDIO_STREAMS <<< "$FFPROBE_OUTPUT"

# Convert duration to a float
DURATION=$(echo "$DURATION_STR" | cut -d'.' -f1-2) # Keep decimal for float calculations

# Default to 0 if DURATION is empty or non-numeric
if ! [[ "$DURATION" =~ ^[0-9]*\.?[0-9]+$ ]]; then
    DURATION="0.0"
fi

TWO_MINUTES="120.0" # seconds

START_TIME="0.0"
SEGMENT_DURATION="$DURATION"

# Use bc for floating point comparisons and calculations
if (( $(echo "$DURATION >= $TWO_MINUTES" | bc -l) )); then
    SEGMENT_DURATION="$TWO_MINUTES"
    # Calculate start time for the 50% mark, ensuring the segment is centered
    # (DURATION / 2) - (SEGMENT_DURATION / 2)
    START_TIME=$(echo "($DURATION / 2.0) - ($SEGMENT_DURATION / 2.0)" | bc -l)
    
    # Ensure start_time is not negative
    if (( $(echo "$START_TIME < 0.0" | bc -l) )); then
        START_TIME="0.0"
    fi
fi

# Use SEGMENT_DURATION as TRIM_DURATION
TRIM_DURATION="$SEGMENT_DURATION"

echo "Calling index.sh with trim arguments: --trim-start $START_TIME --duration $TRIM_DURATION"

# Build the command for index.sh, including the resolution flag and trim flags
INDEX_COMMAND="./index.sh"
if [ -n "$SELECTED_RESOLUTION" ]; then
    INDEX_COMMAND="$INDEX_COMMAND -r $SELECTED_RESOLUTION"
fi
INDEX_COMMAND="$INDEX_COMMAND --trim-start \"$START_TIME\" --duration \"$TRIM_DURATION\"" # Changed to --duration
INDEX_COMMAND="$INDEX_COMMAND \"$INPUT_FILE\""

eval "$INDEX_COMMAND"

INDEX_EXIT_CODE=$?

if [ $INDEX_EXIT_CODE -eq 0 ]; then
    echo "✅ test.sh completed successfully using index.sh"
else
    echo "❌ test.sh failed during index.sh execution."
    exit $INDEX_EXIT_CODE
fi