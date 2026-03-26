#!/bin/bash

echo "🎢 Frame Journey – Doctor"
echo "----------------------------------"

PASS="✅"
FAIL="❌"

error_count=0

check() {
  if "$@" >/dev/null 2>&1; then
    echo "$PASS $*"
  else
    echo "$FAIL $*"
    error_count=$((error_count + 1))
  fi
}

echo "🖥 OS Check"
OS="$(uname -s)"
case "$OS" in
  Linux*)  echo "$PASS Linux detected" ;;
  Darwin*) echo "$PASS macOS detected" ;;
  *)
    echo "$FAIL Unsupported OS: $OS"
    error_count=$((error_count + 1))
    ;;
esac

echo
echo "🎬 FFmpeg Check"
check command -v ffmpeg
check command -v ffprobe

if command -v ffmpeg >/dev/null 2>&1; then
  echo "$PASS $(ffmpeg -version | head -n 1)"
fi

echo
echo "🎥 Codec Support"
check ffmpeg -encoders | grep -q libx264
check ffmpeg -decoders | grep -q h264

echo
echo "📐 Filter Support"
check ffmpeg -filters | grep -q scale
check ffmpeg -filters | grep -q aresample

echo
echo "🎧 Audio Codec Support"
check ffmpeg -encoders | grep -q aac
check ffmpeg -decoders | grep -q aac

echo
echo "⚡ GPU Encoder Check (Optional)"
if ffmpeg -encoders | grep -q nvenc; then
  echo "$PASS NVIDIA NVENC available"
else
  echo "ℹ️  NVENC not found (CPU encoding will be used)"
fi

if ffmpeg -encoders | grep -q vaapi; then
  echo "$PASS VAAPI available"
else
  echo "ℹ️  VAAPI not found"
fi

echo
echo "📁 Project Structure Check"

required_files=(
  "bin/frame-journey"
  "install.sh"
  "config/encoding_profiles.sh"
  "libexec/utils/ffprobe.sh"
  "libexec/audio/extract_sample.sh"
  "libexec/audio/detect_language.sh"
  "libexec/audio/select_audio.sh"
  "libexec/video/select_resolution.sh"
  "libexec/video/transcode_1080p.sh"
  "libexec/video/transcode_720p.sh"
)

for file in "${required_files[@]}"; do
  if [ -f "$file" ]; then
    echo "$PASS $file"
  else
    echo "$FAIL Missing $file"
    error_count=$((error_count + 1))
  fi
done

echo
echo "🔐 Permission Check"
NON_EXECUTABLE_SCRIPTS=$(find . -name "*.sh" ! -perm -111 -type f)
if [ -n "$NON_EXECUTABLE_SCRIPTS" ]; then
  echo "⚠️  Some scripts are not executable"
  echo "$NON_EXECUTABLE_SCRIPTS"
  echo "   Run: chmod +x **/*.sh"
else
  echo "$PASS All scripts executable"
fi

echo
echo "----------------------------------"

if [ "$error_count" -eq 0 ]; then
  echo "🎉 Frame Journey is healthy and ready!"
else
  echo "⚠️  Doctor found $error_count issue(s)"
  echo "Fix the above and run doctor.sh again"
fi
