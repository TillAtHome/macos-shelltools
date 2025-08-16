#!/usr/bin/env bash
set -euo pipefail

PROFILE_FILE="$HOME/Skripte/Macdark.terminal"
PROFILE_NAME="Macdark"

SEARCH_DIR="$(dirname "$PROFILE_FILE")"

# 0) Alle .terminal-Profile im Suchordner importieren (stört nicht, wenn bereits vorhanden)
#    -g = im Hintergrund öffnen (Terminal wird nicht nach vorn geholt)
if compgen -G "$SEARCH_DIR/*.terminal" >/dev/null; then
  while IFS= read -r -d '' f; do
    open -g "$f"
  done < <(find "$SEARCH_DIR" -type f -name "*.terminal" -print0 2>/dev/null)
else
  # Fallback: zumindest das gewünschte Profil importieren
  open -g "$PROFILE_FILE"
fi

# 1) Warten, bis das Zielprofil in den Terminal-Einstellungen gelandet ist
for i in {1..40}; do
  if defaults read com.apple.Terminal "Window Settings" 2>/dev/null | grep -q "\"$PROFILE_NAME\" ="; then
    break
  fi
  sleep 0.25
done

# 2) Default- & Startup-Profil per AppleScript setzen
/usr/bin/osascript <<'APPLESCRIPT'
on run
  set targetProfile to "Macdark"
  tell application "Terminal"
    if not (exists settings set targetProfile) then error "Profil '" & targetProfile & "' nicht gefunden."
    set default settings to settings set targetProfile
    set startup settings to settings set targetProfile
  end tell
end run
APPLESCRIPT

echo "OK: Alle .terminal-Profile aus '$SEARCH_DIR' importiert. '$PROFILE_NAME' ist als Default/Startup gesetzt."