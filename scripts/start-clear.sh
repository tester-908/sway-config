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

for ((i = 0; i < ${#SCREENS[@]}; i++)); do
    SCREEN=${SCREENS[i]}
    STATE_FILE="/tmp/clear-screen-state-$i"
    WORKSPACE="clear$((i + 1))"

    swaymsg -t get_workspaces | jq -r --arg output "$SCREEN" '
        .[] | select(.output == $output and .visible) | .name
    ' > "$STATE_FILE"

    swaymsg "workspace \"$WORKSPACE\" output $SCREEN"
    swaymsg "focus output $SCREEN; workspace \"$WORKSPACE\""
done

swaymsg 'mode "clear"'
killall -SIGUSR1 waybar