#!/bin/bash

WALLPAPER_DIR="$HOME/.config/themes/wallpapers"
OUTPUT_DIR="/tmp/wallpaper-parts"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS_FILE="$SCRIPT_DIR/../settings.json"

if ! SCREEN_LIST=$(jq -er '
    .screens
    | to_entries
    | map(select(.value.enabled == true))
    | sort_by(.value.position[0])
    | .[].key
' "$SETTINGS_FILE"); then
    echo "Unable to read enabled screens from $SETTINGS_FILE" >&2
    exit 1
fi

mapfile -t MONITORS <<< "$SCREEN_LIST"
SCREEN_COUNT=${#MONITORS[@]}
if [[ $SCREEN_COUNT -eq 0 ]]; then
    echo "No enabled screens found in $SETTINGS_FILE" >&2
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Pick a random wallpaper
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
    | shuf -n 1)

if [[ -z "$WALLPAPER" ]]; then
    echo "No wallpapers found!"
    exit 1
fi

echo "Selected: $WALLPAPER"

# Get image dimensions
WIDTH=$(magick identify -format '%w' "$WALLPAPER")
HEIGHT=$(magick identify -format '%h' "$WALLPAPER")

if [[ $WIDTH -lt $SCREEN_COUNT ]]; then
    echo "Wallpaper is too narrow to split across $SCREEN_COUNT screens" >&2
    exit 1
fi

# Split wallpaper
for ((i = 0; i < SCREEN_COUNT; i++)); do
    X=$((i * WIDTH / SCREEN_COUNT))
    NEXT_X=$(((i + 1) * WIDTH / SCREEN_COUNT))
    PART_WIDTH=$((NEXT_X - X))

    magick "$WALLPAPER" \
        -crop "${PART_WIDTH}x${HEIGHT}+${X}+0" \
        +repage \
        "$OUTPUT_DIR/part-$i.png"
done

# Stop previous swaybg instance
pkill swaybg 2>/dev/null

# Launch one swaybg instance for all monitors
SWAYBG_ARGS=()
for ((i = 0; i < SCREEN_COUNT; i++)); do
    SWAYBG_ARGS+=(-o "${MONITORS[i]}" -i "$OUTPUT_DIR/part-$i.png" -m fill)
done

swaybg "${SWAYBG_ARGS[@]}" &

echo "Wallpaper applied!"