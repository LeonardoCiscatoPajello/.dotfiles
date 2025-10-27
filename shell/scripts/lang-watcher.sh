#!/usr/bin/env bash
# Place this script inside the hypr directory under config at this path: ~/.config/hypr/scripts/lang-watcher.sh

ICON="$HOME/.config/mako/icons/kb.png" # <-- this png is not provided on the repo, find yours

get_lang() {
  layout="$1"
  lang="${layout:0:2}"
  lang="$(printf "%s" "$lang" | tr 'A-Z' 'a-z')"
  case "$lang" in
    en) echo "English";;
    it) echo "Italiano";;
    *)  echo "${layout:-Unknown}";;
  esac
}

# Initial notification
initial_layout="$(hyprctl devices -j 2>/dev/null | jq -r '.keyboards[0].active_keymap' 2>/dev/null || echo "Unknown")"
notify-send -h string:x-canonical-private-synchronous:kbd-layout -u low -i "$ICON" "Keyboard Layout" "$(get_lang "$initial_layout")"

# Event loop
socat -u UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - \
  | while IFS=',' read -r event_type layout_name; do
    if [[ "$event_type" == activelayout* ]]; then
      # Extract layout after comma
      layout="${layout_name#*,}"
      notify-send -h string:x-canonical-private-synchronous:kbd-layout -u low -i "$ICON" "Keyboard Layout" "$(get_lang "$layout")"
    fi
  done 
  # ⟦ΔΒ⟧
