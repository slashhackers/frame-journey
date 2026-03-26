#!/bin/bash

# progress_monitor.sh
# Monitors ffmpeg -progress output and displays a progress bar with ETA.

# Arguments:
# $1: Total duration of the video segment in seconds.

TOTAL_DURATION="${1:-0}"
BAR_LENGTH=50 # Length of the progress bar in characters

# Initialize variables to avoid bc errors
CURRENT_TIME_SEC=0
SPEED=0
PERCENT=0

function format_time() {
  local SECONDS_VAL=$1
  # Handle non-numeric or empty input
  if [[ ! "$SECONDS_VAL" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    SECONDS_VAL=0
  fi
  
  # Round to nearest integer for simple shell arithmetic
  local SECONDS_INT=$(printf "%.0f" "$SECONDS_VAL" 2>/dev/null || echo 0)
  
  if (( SECONDS_INT < 0 )); then
    SECONDS_INT=0
  fi
  printf "%02d:%02d:%02d" $((SECONDS_INT/3600)) $(( (SECONDS_INT%3600)/60 )) $((SECONDS_INT%60))
}

# Clear line and move cursor to beginning
function clear_line() {
  printf "\r\033[K"
}

# Helper to safely call bc
safe_bc() {
  local result
  result=$(echo "$@" | bc -l 2>/dev/null)
  if [[ -z "$result" ]]; then
    echo "0"
  else
    echo "$result"
  fi
}

# Main loop to read ffmpeg progress output
while IFS='=' read -r key value; do
  # Remove leading/trailing whitespace from value
  value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  
  case "$key" in
    out_time_ms)
      # ffmpeg reports in microseconds
      if [[ "$value" =~ ^[0-9]+$ ]]; then
        CURRENT_TIME_SEC=$(safe_bc "scale=3; $value / 1000000")
      fi
      ;;
    speed)
      # Speed is like "2.500x" or "  0.1x"
      CLEAN_SPEED=$(echo "$value" | sed 's/x//')
      if [[ "$CLEAN_SPEED" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        SPEED="$CLEAN_SPEED"
      else
        SPEED=0
      fi
      ;;
    progress)
      if [ "$value" = "continue" ] || [ "$value" = "end" ]; then
        # Check if TOTAL_DURATION is a valid number > 0
        if [[ "$TOTAL_DURATION" =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(safe_bc "$TOTAL_DURATION > 0") )); then
          PERCENT=$(safe_bc "scale=2; ($CURRENT_TIME_SEC / $TOTAL_DURATION) * 100")
          if (( $(safe_bc "$PERCENT > 100") )); then
            PERCENT=100.00
          fi
        else
          PERCENT=0.00
        fi

        if (( $(safe_bc "$PERCENT < 0") )); then
          PERCENT=0.00
        fi

        # Calculate ETA
        ETA_SECONDS=-1
        if [[ "$SPEED" =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(safe_bc "$SPEED > 0") )) && \
           [[ "$CURRENT_TIME_SEC" =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(safe_bc "$CURRENT_TIME_SEC > 0") )) && \
           [[ "$TOTAL_DURATION" =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(safe_bc "$TOTAL_DURATION > 0") )); then
            # Remaining duration = Total - Current
            # ETA = Remaining duration / Speed
            REMAINING_DURATION=$(safe_bc "scale=2; $TOTAL_DURATION - $CURRENT_TIME_SEC")
            if (( $(safe_bc "$REMAINING_DURATION > 0") )); then
              ETA_SECONDS=$(safe_bc "scale=0; $REMAINING_DURATION / $SPEED")
            else
              ETA_SECONDS=0
            fi
        fi

        # Progress bar
        NUM_CHARS=$(safe_bc "scale=0; ($PERCENT / 100) * $BAR_LENGTH")
        # Ensure NUM_CHARS is an integer for printf
        NUM_CHARS=$(printf "%.0f" "$NUM_CHARS" 2>/dev/null || echo 0)
        
        if (( NUM_CHARS < 0 )); then NUM_CHARS=0; fi
        if (( NUM_CHARS > BAR_LENGTH )); then NUM_CHARS=$BAR_LENGTH; fi

        BAR_FILLED=$(printf "%${NUM_CHARS}s" | tr ' ' '#')
        BAR_EMPTY=$(printf "%$((BAR_LENGTH - NUM_CHARS))s" | tr ' ' '-')

        clear_line
        if [[ "$TOTAL_DURATION" =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(safe_bc "$TOTAL_DURATION > 0") )); then
          if (( $(safe_bc "$ETA_SECONDS >= 0") )); then
            printf "Progress: |%s%s| %.2f%% (ETA: %s)" "$BAR_FILLED" "$BAR_EMPTY" "$PERCENT" "$(format_time "$ETA_SECONDS")"
          else
            printf "Progress: |%s%s| %.2f%%" "$BAR_FILLED" "$BAR_EMPTY" "$PERCENT"
          fi
        else
          # If no total duration, just show current time
          printf "Progress: %s (speed: %sx)" "$(format_time "$CURRENT_TIME_SEC")" "$SPEED"
        fi

        if [ "$value" = "end" ]; then
          echo "" # Newline after completion
          break
        fi
      fi
      ;;
  esac
done < /dev/stdin
