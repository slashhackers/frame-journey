#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
# Get project root
PROJECT_ROOT=$(dirname "$(dirname "$SCRIPT_DIR")")

source "$PROJECT_ROOT/config/encoding_profiles.sh"

INPUT_FILE="$1"
AUDIO_INDEX="$2"
OUTPUT_FILE="$3"
TRIM_START=""
DURATION="" 
PROGRESS_DURATION=""
METADATA_TITLE=""
METADATA_DESCRIPTION=""

# Parse additional arguments for trim-start and duration
shift 3 # Shift past the positional arguments
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --trim-start)
      TRIM_START="$2"
      shift
      ;;
    --duration)
      DURATION="$2"
      shift
      ;;
    --progress-duration)
      PROGRESS_DURATION="$2"
      shift
      ;;
    --title)
      METADATA_TITLE="$2"
      shift
      ;;
    --description)
      METADATA_DESCRIPTION="$2"
      shift
      ;;
    *)
      echo "Invalid argument for transcode_480p.sh: $1" >&2
      exit 1
      ;;
  esac
  shift
done

# Build FFmpeg trim options
FFMPEG_TRIM_OPTIONS=""
if [ -n "$TRIM_START" ]; then
  FFMPEG_TRIM_OPTIONS+="-ss \"$TRIM_START\" "
fi
if [ -n "$DURATION" ]; then
  FFMPEG_TRIM_OPTIONS+="-t \"$DURATION\" "
fi

# Build Metadata options
# -map_metadata -1 clears existing global metadata
# Then we set title and description
METADATA_OPTIONS="-map_metadata -1 -metadata title=\"$METADATA_TITLE\" -metadata description=\"$METADATA_DESCRIPTION\""

echo "Starting 480p encoding"
eval "ffmpeg -y -nostats -loglevel error -progress pipe:1 -i \"${INPUT_FILE}\" ${FFMPEG_TRIM_OPTIONS} \
  -map 0:v:0 -map 0:a:\"${AUDIO_INDEX}\" \
  ${METADATA_OPTIONS} \
  -c:v h264_videotoolbox \
  -b:v $BITRATE_480 \
  -pix_fmt yuv420p \
  -g 48 \
  -keyint_min 48 \
  -vf scale=$SCALE_480 \
  -movflags +faststart \
  -c:a aac -b:a 128k \
  \"${OUTPUT_FILE}\"" | bash "$PROJECT_ROOT/libexec/utils/progress_monitor.sh" "$PROGRESS_DURATION"

FFMPEG_EXIT_CODE=${PIPESTATUS[0]}
if [ $FFMPEG_EXIT_CODE -ne 0 ]; then
    echo "❌ 480p encoding failed (exit code: $FFMPEG_EXIT_CODE)"
    exit 1
fi

echo "✅ 480p encoding complete"
