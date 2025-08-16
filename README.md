# macOS Setup Scripts

Systemnahe, minimalistische Shellskripte zur Konfiguration, Wiederherstellung und Individualisierung von macOS (Zsh, Terminal, Finder, Launchd, Homebrew).

## Struktur

```
zsh/
  zprofile.txt         → Vorlage für .zprofile
  zshrc.txt            → Vorlage für .zshrc

scripts/
  macsetup.sh          → Hauptskript für neue macOS-Installationen
  finder-reset.sh      → Finder-, Dock- und Defaults-Reset inkl. Cache-Säuberung
  terminalprofil.sh    → Terminal-Profile importieren und als Standard setzen
  goto_folder.sh       → „Gehe zu Ordner“-Verlauf im Finder löschen
  snap.sh              → Lokale Time Machine Snapshots entfernen
  trash.sh             → Dateireste nach App-Deinstallationen finden
```

## Hinweise

- Getestet unter macOS 14 (Sonoma) und 15 (Sequoia)
- Keine externen Frameworks, keine Abhängigkeiten
- Homebrew empfohlen für aktuelle `bash`, `nano`, `grep` etc.
- Alle Skripte sind kommentiert, anpassbar und portabel
- Keine Telemetrie, kein Netzwerkzugriff (außer bei Homebrew-Installation)

## Lizenz

MIT License – freie Nutzung mit Namensnennung.  
Autor: **TilliAtHome**
