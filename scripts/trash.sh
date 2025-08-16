#!/usr/bin/env bash
# Sucht nach Restdateien deinstallierter Apps – externe Volumes & Backups werden ignoriert
# BSD-/POSIX-kompatibel (macOS /bin/sh)

clear

###############################################################################
# 1 · Robustheit & Root-Check
###############################################################################
set -eu
IFS='
'

if [ "$(id -u)" -ne 0 ]; then
  echo "Bitte mit sudo ausführen, sonst fehlen Treffer."
  exit 1
fi

###############################################################################
# 2 · Ausgabedatei vorbereiten
###############################################################################
OUTFILE="$HOME/suche.txt"
date '+%Y-%m-%d %H:%M:%S' > "$OUTFILE"
echo >> "$OUTFILE"

###############################################################################
# 3 · Suchbegriff abfragen
###############################################################################
printf "Suchbegriff: "
read -r suchbegriff || true
case $(printf '%s' "$suchbegriff" | tr -d '[:space:]') in
  '') echo "Kein Suchbegriff." >&2; exit 1 ;;
esac

echo "Suchergebnisse für: $suchbegriff" >> "$OUTFILE"
printf '====================================\n\n' >> "$OUTFILE"

###############################################################################
# 4 · Fortschritts-Spinner (ASCII, portabel)
###############################################################################
progress_bar() {
  pid=$1
  sp='-\|/'
  i=0
  while kill -0 "$pid" 2>/dev/null; do
    c=$(printf %s "$sp" | cut -c $(( (i % 4) + 1 )))
    printf "\rScanne … %s" "$c"
    i=$((i + 1))
    sleep 0.1
  done
  printf "\r\033[K"
}

append() { printf "%s\n" "$1" >> "$OUTFILE"; }
header()  { printf "\n--- %s ---\n" "$1" >> "$OUTFILE"; }

###############################################################################
# 5 · Dateisystem-Suche (Pfad-Matches)
###############################################################################
(
  header "Dateisystem-Treffer (Pfad-Matches)"
  # -xdev: nur interne Volumes
  LC_ALL=C find / /System/Volumes/Data -xdev \
      \( -path '/Volumes/*' -o -path '*/.timemachine/*' -o -path '*/Backups.backupdb/*' -o \
         -path '*/.Spotlight-V100/*' -o -path '*/.DocumentRevisions-V100/*' -o \
         -path '*/.fseventsd/*' -o -path '*/.Trash/*' \) -prune -o \
      -ipath "*${suchbegriff}*" -print 2>/dev/null
) >> "$OUTFILE" &
find_pid=$!

progress_bar "$find_pid"
if ! wait "$find_pid"; then
  echo "Warnung: 'find' meldete Fehler (zugriffsgeschützte Pfade sind normal)." >&2
fi

###############################################################################
# 6 · launchd-Plists: Dateiname ODER Label/ProgramArguments (ohne Spotlight)
###############################################################################
header "launchd-Treffer (Dateiname oder Label/ProgramArguments)"

# Verzeichnisse sammeln (newline-separierte Liste, statt Array)
LAUNCH_DIRS='/Library/LaunchAgents
/Library/LaunchDaemons
/System/Library/LaunchAgents
/System/Library/LaunchDaemons'

# Alle User-LaunchAgents ergänzen
if command -v dscl >/dev/null 2>&1; then
  dscl . -list /Users NFSHomeDirectory 2>/dev/null \
    | awk '{print $3}' \
    | grep -E '^/Users/[^/]+$' \
    | while IFS= read -r userhome; do
        if [ -d "$userhome/Library/LaunchAgents" ]; then
          LAUNCH_DIRS=$(printf '%s\n%s' "$LAUNCH_DIRS" "$userhome/Library/LaunchAgents")
        fi
      done
fi

# Plist-Inhalt dumpen (robust)
dump_plist() {
  f=$1
  if [ -x /usr/libexec/PlistBuddy ]; then
    /usr/libexec/PlistBuddy -c 'Print' "$f" 2>/dev/null || true
  else
    plutil -p "$f" 2>/dev/null || true
  fi
}

# Escaping-Helfer für grep (ERE) – BSD-sed-kompatibel, entkommt alle relevanten Metazeichen inkl. ']'
esc_grep() {
  printf '%s' "$1" | sed 's/[][\.^$*+?{}()|/\\]/\\&/g'
}

pat_literal=$(esc_grep "$suchbegriff")

# Über alle Launch-Verzeichnisse iterieren
printf '%s\n' "$LAUNCH_DIRS" | while IFS= read -r dir; do
  [ -d "$dir" ] || continue
  # Dateien finden (kein Process Substitution)
  LC_ALL=C find "$dir" -xdev -type f -name "*.plist" -print 2>/dev/null \
    | while IFS= read -r f; do
        [ -f "$f" ] || continue

        # 1) Dateiname/Path enthält Suchbegriff?
        if printf '%s\n' "$f" | grep -Eqi -- "$pat_literal"; then
          append "$f"
          continue
        fi

        # 2) Label/ProgramArguments etc. enthalten Suchbegriff?
        content=$(dump_plist "$f")
        [ -n "$content" ] || continue
        if printf '%s' "$content" | grep -Eqi -- "$pat_literal"; then
          append "$f"
        fi
      done
done

###############################################################################
# 7 · Fertig
###############################################################################
echo "Suche abgeschlossen. Ergebnisse unter: $OUTFILE"