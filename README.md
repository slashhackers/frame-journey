# 🎢 Frame Journey

**Frame Journey** is a high-quality, streaming-optimized **video
processing pipeline** designed to convert raw videos into
**YouTube-style playback formats** with the best balance of quality and
file size.

Just like a roller coaster 🎢 smoothly handles ups, downs, and speed
changes, **Frame Journey** guides every video frame through resolution,
bitrate, and audio decisions---efficiently and safely.

------------------------------------------------------------------------

## 🚀 What is Frame Journey?

Frame Journey accepts videos of any resolution (4K, 1080p, 720p, or
lower) and intelligently produces **stream-ready outputs** without
unnecessary processing or quality loss.

It is built for: - Video streaming platforms - OTT services - Course
platforms - Creator tools - Internal media pipelines

------------------------------------------------------------------------

## 🎯 Core Features

### 🎥 Smart Resolution Handling

-   Supports any input resolution
-   Outputs only:
    -   **1080p** (if input ≥ 1080p)
    -   **720p** (if input ≥ 720p)
-   ❌ No upscaling (natural quality preserved)
-   🎬 YouTube-style encoding profiles

------------------------------------------------------------------------

### 🎧 Intelligent Audio Selection

-   **Single audio track**
    -   Kept as-is (no changes)
-   **Multiple audio tracks**
    -   Extracts a **60-second audio sample**
    -   Detects **Hindi vs English**
    -   Prefers **Hindi**
    -   Falls back gracefully if Hindi is unavailable

------------------------------------------------------------------------

### 📦 Streaming-Optimized Output

-   H.264 (libx264)
-   Streaming-friendly bitrates
-   `faststart` enabled for instant playback
-   Optimized for MP4 → HLS/DASH workflows

----------------------------------------

## 🧱 Project Structure

    frame-journey/
    ├── bin/
    │   └── frame-journey (Main entry point)
    ├── libexec/
    │   ├── audio/ (Audio processing)
    │   ├── video/ (Transcoding scripts)
    │   └── utils/ (Core utilities)
    ├── config/
    │   └── encoding_profiles.sh
    ├── install.sh (Professional installer)
    ├── doctor.sh (System health check)
    └── README.md

----------------------------------------

## 🚀 Installation

### 1. Quick Install (One-liner)
Install `frame-journey` directly from GitHub into your local system:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/slashhackers/frame-journey/main/install.sh)"
```

### 2. Manual Installation
If you prefer to clone the repository first:

```bash
git clone https://github.com/slashhackers/frame-journey.git
cd frame-journey
chmod +x install.sh
./install.sh
```

### 3. Verify the installation
```bash
chmod +x doctor.sh
./doctor.sh
```

----------------------------------------

## ▶️ Usage

After installation, you can run `frame-journey` from any directory:

```bash
frame-journey input.mp4
```

### Options:
- `-h, --help`: Show the help message.
- `-v, --version`: Show the current version.
- `--update`: Check for and install updates.
- `--dry-run`: Show what would be done without actual transcoding.
- `-r <resolution>`: Select output resolution (720, 1080).
- `--trim-start <time>`: Start time (e.g., 00:00:10).
- `--duration <length>`: Duration (e.g., 60).
- `--show-progress`: Show a live progress bar.
- `-o <output_filename>`: Custom output filename.
- `--audio <index>`: Explicitly select an audio track index.

------------------------------------------------------------------------

## 🏁 Vision

> *Every frame has a journey. We make sure it's smooth with just basic tools* 🎢
