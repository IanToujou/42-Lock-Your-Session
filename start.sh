#! /bin/bash

stop_image_script() {
    if [ ! -z "$IMAGE_PID" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Stopping image.py (PID: $IMAGE_PID)"
        kill "$IMAGE_PID" 2>/dev/null
        IMAGE_PID=""
    fi
}

display_frame() {
  local text=("$@")
  local rows=${#text[@]}
  local terminal_rows=$(tput lines)
  local terminal_cols=$(tput cols)

  local max_cols=0
  for line in "${text[@]}"; do
    local line_len=${#line}
    if [ $line_len -gt $max_cols ]; then
      max_cols=$line_len
    fi
  done

  local start_row=$(( ( terminal_rows - rows ) / 2 ))
  local start_col=$(( ( terminal_cols - max_cols ) / 2 ))

  if [ $start_row -lt 0 ]; then
    start_row=0
  fi
  if [ $start_col -lt 0 ]; then
    start_col=0
  fi

  clear

  for (( i=0; i<rows; i++)); do
    local row_pos=$(( start_row + i ))
    if [ $row_pos -lt $terminal_rows ]; then
      tput cup "$row_pos" "$start_col"
      echo -e "${text[$i]}"
    fi
  done
  sleep 0.06
}

run_animation() {
  local animation_name="$1"

  if [ -z "$animation_name" ]; then
    echo "Error: animation name is required"
    echo "Usage: $0 animation <name>"
    exit 1
  fi

  cd "animation/$animation_name/" || exit 1
  tput civis

  frames=$(cat frameList)

  while true; do
    for frame in $frames; do
      frameText=()
      while IFS= read -r line; do
        frameText+=("$line")
      done < "$frame"
      display_frame "${frameText[@]}"
    done
  done
}

subcommand="$1"

case "$subcommand" in
  animation)
    animation_name="$2"
    run_animation "$animation_name"
    ;;
  lock)
    LAST_STATE="unlocked"
    while true; do
      LOCK_COUNT=$(pgrep -c ft_lock)
        if [ "$LOCK_COUNT" -ge 2 ]; then
            if [ "$LAST_STATE" = "unlocked" ]; then
                LAST_STATE="locked"
                ./script/display_image.py &
                IMAGE_PID=$!
            fi
        else
            if [ "$LAST_STATE" = "locked" ]; then
                stop_image_script
                LAST_STATE="unlocked"
            fi
            sleep 0.5
        fi
    done
    ;;
  *)
    echo "Usage: $0 {animation|lock} [name]"
    echo "  animation <name>  - Run animation (name required)"
    echo "  lock              - Execute lock script"
    exit 1
    ;;
esac

tput cnorm