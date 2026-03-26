#!/bin/bash
# video_info.sh
# Extract video information and output in JSON or human-readable format.

INPUT_FILE="$1"
FORMAT="$2" # "json" or "text"

if [ -z "$INPUT_FILE" ]; then
  echo "Error: No input file provided." >&2
  exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
  echo "Error: Input file '$INPUT_FILE' not found." >&2
  exit 1
fi

# Use ffprobe to get comprehensive info in JSON format
JSON_INFO=$(ffprobe -v quiet -print_format json -show_format -show_streams "$INPUT_FILE")

# Process with python for consistent extraction across both formats
python3 - <<EOF
import json
import sys
import os

data = json.loads('''$JSON_INFO''')
format_type = "$FORMAT"

format_info = data.get('format', {})
streams = data.get('streams', [])

file_path = format_info.get('filename', 'Unknown')
file_name = os.path.basename(file_path)
size_bytes = int(format_info.get('size', 0))
duration = float(format_info.get('duration', 0))
title = format_info.get('tags', {}).get('title', 'Unknown')
description = format_info.get('tags', {}).get('description', 'None')

def human_readable_size(bytes):
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if bytes < 1024.0:
            return f"{bytes:.2f} {unit}"
        bytes /= 1024.0
    return f"{bytes:.2f} PB"

def format_duration(seconds):
    h = int(seconds // 3600)
    m = int((seconds % 3600) // 60)
    s = seconds % 60
    parts = []
    if h > 0: parts.append(f"{h}h")
    if m > 0: parts.append(f"{m}m")
    parts.append(f"{s:.2f}s")
    return " ".join(parts)

video_stream = next((s for s in streams if s['codec_type'] == 'video'), {})
width = video_stream.get('width', 'Unknown')
height = video_stream.get('height', 'Unknown')
resolution = f"{width}x{height}"

audio_tracks = []
for s in streams:
    if s['codec_type'] == 'audio':
        lang = s.get('tags', {}).get('language', 'Unknown')
        index = s.get('index')
        audio_tracks.append({"index": index, "language": lang})

subtitles = []
for s in streams:
    if s['codec_type'] == 'subtitle':
        lang = s.get('tags', {}).get('language', 'Unknown')
        index = s.get('index')
        subtitles.append({"index": index, "language": lang})

# Filter out tags we already showed
tags = format_info.get('tags', {})
other_props = {k: v for k, v in tags.items() if k.lower() not in ['title', 'description']}

if format_type == "json":
    minimal_json = {
        "file_info": {
            "file_name": file_name,
            "media_name": title,
            "size": {
                "bytes": size_bytes,
                "human": human_readable_size(size_bytes)
            },
            "resolution": resolution,
            "duration": {
                "seconds": duration,
                "human": format_duration(duration)
            },
            "description": description
        },
        "audio_languages": audio_tracks,
        "subtitles": subtitles,
        "other_metadata": other_props
    }
    print(json.dumps(minimal_json, indent=4))
else:
    # Beautified output
    print("\033[1;34m" + "=" * 50 + "\033[0m")
    print("\033[1;32m   VIDEO INFORMATION\033[0m")
    print("\033[1;34m" + "=" * 50 + "\033[0m")
    print(f"\033[1mFile Name:\033[0m      {file_name}")
    print(f"\033[1mMedia Name:\033[0m     {title}")
    print(f"\033[1mSize:\033[0m           {human_readable_size(size_bytes)}")
    print(f"\033[1mResolution:\033[0m     {resolution}")
    print(f"\033[1mDuration:\033[0m       {format_duration(duration)} ({duration:.2f}s)")
    print(f"\033[1mDescription:\033[0m    {description}")

    print("\n\033[1mAudio Languages:\033[0m")
    if audio_tracks:
        for track in audio_tracks:
            print(f"  Track {track['index']}: {track['language']}")
    else:
        print("  None found")

    print("\n\033[1mAvailable Subtitles:\033[0m")
    if subtitles:
        for sub in subtitles:
            print(f"  Track {sub['index']}: {sub['language']}")
    else:
        print("  None found")

    if other_props:
        print("\n\033[1mOther Metadata:\033[0m")
        for k, v in other_props.items():
            print(f"  {k}: {v}")

    print("\033[1;34m" + "=" * 50 + "\033[0m")
EOF
