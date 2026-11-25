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

for SCREEN in "${SCREENS[@]}"; do
    if ! swaymsg "output \"$SCREEN\" power toggle"; then
        echo "Unable to toggle power for output $SCREEN" >&2
        exit 1
    fi
done