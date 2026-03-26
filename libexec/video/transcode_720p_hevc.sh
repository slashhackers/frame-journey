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
    --title)
      METADATA_TITLE="$2"
      shift
      ;;
    --description)
      METADATA_DESCRIPTION="$2"
      shift
      ;;
    *)
      echo "Invalid argument for transcode_720p_hevc.sh: $1" >&2
      exit 1
      ;;
  esac
  shift
done

# Build FFmpeg trim options - these will now be placed AFTER -i
FFMPEG_TRIM_OPTIONS=""
if [ -n "$TRIM_START" ]; then
  FFMPEG_TRIM_OPTIONS+="-ss \"$TRIM_START\" "
fi
if [ -n "$DURATION" ]; then
  FFMPEG_TRIM_OPTIONS+="-t \"$DURATION\" "
fi

# Build Metadata options
METADATA_OPTIONS="-map_metadata -1 -metadata title=\"$METADATA_TITLE\" -metadata description=\"$METADATA_DESCRIPTION\""

echo "Starting 720p HEVC encoding"
eval "ffmpeg -y -loglevel error -i \"${INPUT_FILE}\" ${FFMPEG_TRIM_OPTIONS} \
  -map 0:v:0 -map 0:a:\"${AUDIO_INDEX}\" \
  ${METADATA_OPTIONS} \
  -c:v hevc_videotoolbox \
  -b:v $BITRATE_720 \
  -tag:v hvc1 \
  -profile:v main \
  -pix_fmt yuv420p \
  -g 48 \
  -keyint_min 48 \
  -vf scale=$SCALE_720 \
  -movflags +faststart \
  -c:a aac -b:a 128k \
  \"${OUTPUT_FILE}\""

FFMPEG_EXIT_CODE=$?
if [ $FFMPEG_EXIT_CODE -ne 0 ]; then
    echo "❌ 720p HEVC encoding failed (exit code: $FFMPEG_EXIT_CODE)"
    exit 1
fi

echo "✅ 720p HEVC encoding complete"

# Note: For HEVC, you can often achieve similar visual quality with a lower bitrate
# than H.264. Consider adjusting BITRATE_720 in config/encoding_profiles.sh
# for the HEVC transcodes if you want to optimize for file size.
