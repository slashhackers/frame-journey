#!/bin/bash

# progress_monitor.sh
# Monitors ffmpeg -progress output and displays a progress bar with ETA.

# Arguments:
# $1: Total duration of the video segment in seconds.

TOTAL_DURATION="$1"
BAR_LENGTH=50 # Length of the progress bar in characters

function format_time() {
  local SECONDS=$1
  if (( SECONDS < 0 )); then
    SECONDS=0
  fi
  printf "%02d:%02d:%02d" $((SECONDS/3600)) $(( (SECONDS%3600)/60 )) $((SECONDS%60))
}

# Clear line and move cursor to beginning
function clear_line() {
  printf "\033[K"
}

# Main loop to read ffmpeg progress output
while IFS='=' read -r key value; do
  case "$key" in
    out_time_ms)
      # ffmpeg reports in microseconds
      CURRENT_TIME_MS="$value"
      CURRENT_TIME_SEC=$(echo "scale=3; $CURRENT_TIME_MS / 1000000" | bc -l)
      ;;
    speed)
      # Speed is like "2.500x"
      SPEED=$(echo "$value" | sed 's/x//')
      ;;
    progress)
      if [ "$value" = "continue" ] || [ "$value" = "end" ]; then
        if (( $(echo "$TOTAL_DURATION > 0" | bc -l) )); then
          PERCENT=$(echo "scale=2; ($CURRENT_TIME_SEC / $TOTAL_DURATION) * 100" | bc -l)
          if (( $(echo "$PERCENT > 100" | bc -l) )); then
            PERCENT=100.00
          fi
        else
          PERCENT=0.00
        fi

        if (( $(echo "$PERCENT < 0" | bc -l) )); then
          PERCENT=0.00
        fi

        # Calculate ETA
        ETA_SECONDS=-1
        if (( $(echo "$SPEED > 0.0" | bc -l) )) && (( $(echo "$CURRENT_TIME_SEC > 0.0" | bc -l) )); then
            # Remaining duration = Total - Current
            # ETA = Remaining duration / Speed
            REMAINING_DURATION=$(echo "scale=2; $TOTAL_DURATION - $CURRENT_TIME_SEC" | bc -l)
            if (( $(echo "$REMAINING_DURATION > 0" | bc -l) )); then
              ETA_SECONDS=$(echo "scale=0; $REMAINING_DURATION / $SPEED" | bc -l)
            else
              ETA_SECONDS=0
            fi
        fi

        # Progress bar
        NUM_CHARS=$(echo "scale=0; ($PERCENT / 100) * $BAR_LENGTH" | bc -l)
        if (( NUM_CHARS < 0 )); then NUM_CHARS=0; fi
        if (( NUM_CHARS > BAR_LENGTH )); then NUM_CHARS=$BAR_LENGTH; fi

        BAR_FILLED=$(printf "%${NUM_CHARS}s" | tr ' ' '#')
        BAR_EMPTY=$(printf "%$((BAR_LENGTH - NUM_CHARS))s" | tr ' ' '-')

        clear_line
        if (( ETA_SECONDS >= 0 )); then
          printf "Progress: |%s%s| %.2f%% (ETA: %s)" "$BAR_FILLED" "$BAR_EMPTY" "$PERCENT" "$(format_time $ETA_SECONDS)"
        else
          printf "Progress: |%s%s| %.2f%%" "$BAR_FILLED" "$BAR_EMPTY" "$PERCENT"
        fi

        if [ "$value" = "end" ]; then
          echo "" # Newline after completion
          break
        fi
      fi
      ;;
  esac
done < /dev/stdin
