#!/usr/bin/env bash
# Einfaches Löschen aller lokalen Time-Machine-Snapshots

set -euo pipefail
IFS=$'\n'

# Als root prüfen
if [[ $EUID -ne 0 ]]; then
  echo "Bitte als root ausführen."
  exit 1
fi

read -rp "Alle lokalen Snapshots löschen? (y/N): " ans
case "$ans" in
  [Yy]* ) ;;            # alles okay, weiter
  *     ) echo "Abbruch."; exit 0 ;;
esac

for vol in / /System/Volumes/Data; do
  [[ -d $vol ]] || continue
  echo "Volume: $vol"
  tmutil listlocalsnapshots "$vol" \
    | sed -n 's/^com\.apple\.TimeMachine\.\(.*\)\.local$/\1/p' \
    | while read -r snap; do
        echo "→ lösche $snap"
        tmutil deletelocalsnapshots "$snap"
      done
done

echo "Fertig."