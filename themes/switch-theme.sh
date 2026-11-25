#!/bin/bash

THEMES="$HOME/.config/themes"
CURRENT="$THEMES/current"

# ------------------------------------------------------------
# Determine current theme
# ------------------------------------------------------------

if [[ "$(readlink "$CURRENT")" == "$THEMES/dark" ]]; then
    NEXT="light"
else
    NEXT="dark"
fi

echo "Switching to $NEXT theme..."

# ------------------------------------------------------------
# Switch current theme
# ------------------------------------------------------------

rm -f "$CURRENT"
ln -s "$THEMES/$NEXT" "$CURRENT"

# ------------------------------------------------------------
# Wofi
# ------------------------------------------------------------

rm -f "$HOME/.config/wofi"
ln -s "$CURRENT/wofi" "$HOME/.config/wofi"

# ------------------------------------------------------------
# nwg-drawer
# ------------------------------------------------------------

rm -f "$HOME/.config/nwg-drawer"
ln -s "$CURRENT/nwg-drawer" "$HOME/.config/nwg-drawer"

# ------------------------------------------------------------
# nwg-bar
# ------------------------------------------------------------

rm -f "$HOME/.config/nwg-bar"
ln -s "$CURRENT/nwg-bar" "$HOME/.config/nwg-bar"

# ------------------------------------------------------------
# Reload Sway
# ------------------------------------------------------------

swaymsg reload

# ------------------------------------------------------------
# Restart Waybar
# ------------------------------------------------------------

pkill waybar

waybar \
    -c "$CURRENT/waybar/config" \
    -s "$CURRENT/waybar/style.css" &

# ------------------------------------------------------------
# Wallpaper
# ------------------------------------------------------------

swaymsg output "*" bg "$CURRENT/wallpaper.jpg" fill

echo "Theme switched to $NEXT"