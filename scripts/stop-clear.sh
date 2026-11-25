#!/bin/bash

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

mapfile -t SCREENS <<< "$SCREEN_LIST"
if [[ ${#SCREENS[@]} -eq 0 ]]; then
    echo "No enabled screens found in $SETTINGS_FILE" >&2
    exit 1
fi

swaymsg 'mode "default"'
killall -SIGUSR1 waybar

for ((i = 0; i < ${#SCREENS[@]}; i++)); do
    STATE_FILE="/tmp/clear-screen-state-$i"
    if [[ -s "$STATE_FILE" ]]; then
        WORKSPACE=$(cat "$STATE_FILE")

        swaymsg "focus output ${SCREENS[i]}"
        swaymsg "workspace \"$WORKSPACE\""

        rm -f "$STATE_FILE"
    fi
done