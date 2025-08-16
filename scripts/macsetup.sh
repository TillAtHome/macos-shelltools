#!/usr/bin/env bash
set -e  # Skript bricht bei Fehler ab

###############################################################################
# 0) Login-Noise reduzieren
###############################################################################
touch "$HOME/.hushlogin"

###############################################################################
# 1) Vorbedingung: Voller Festplattenzugriff fürs Terminal
###############################################################################
clear
read -p "Hat Terminal bereits vollen Festplattenzugriff? (y/n): " antwort
if [[ "$antwort" != "y" && "$antwort" != "Y" ]]; then
  exit 1
fi

###############################################################################
# 2) Dateien kopieren (übersichtlich, erweiterbar)
#    – Quelle anpassen: /Volumes/Daten SSD
#    – Kopiert nur, wenn Quelle/Dateien existieren
###############################################################################
SRC="/Volumes/Daten SSD"

# Zielordner
mkdir -p "$HOME/Pictures/Wallpaper"
mkdir -p "$HOME/Fortunes/de"
mkdir -p "$HOME/Skripte"

# Einzeldateien
if [[ -f "$SRC/Skripte/zshrc.txt" ]]; then
  cp -n "$SRC/Skripte/zshrc.txt" "$HOME/.zshrc"
fi
if [[ -f "$SRC/Skripte/zprofile.txt" ]]; then
  cp -n "$SRC/Skripte/zprofile.txt" "$HOME/.zprofile"
fi

# Ordnerinhalte (nur wenn es Treffer gibt)
if compgen -G "$SRC/Skripte/*.terminal" > /dev/null; then
  cp -n "$SRC/Skripte/"*.terminal "$HOME/Skripte/"
fi
if compgen -G "$SRC/Skripte/*.sh" > /dev/null; then
  cp -n "$SRC/Skripte/"*.sh "$HOME/Skripte/"
fi
if compgen -G "$SRC/Downloads/*" > /dev/null; then
  cp -n "$SRC/Downloads/"* "$HOME/Downloads/"
fi
if compgen -G "$SRC/Wallpaper/*" > /dev/null; then
  cp -n "$SRC/Wallpaper/"* "$HOME/Pictures/Wallpaper/"
fi
if compgen -G "$SRC/Fortunes/de/*" > /dev/null; then
  cp -n "$SRC/Fortunes/de/"* "$HOME/Fortunes/de/"
fi

# Minimalprüfung: zsh-Konfigs vorhanden?
if [[ ! -s "$HOME/.zprofile" ]]; then
  echo "~/.zprofile fehlt – Setup abgebrochen." >&2
  exit 1
fi
if [[ ! -s "$HOME/.zshrc" ]]; then
  echo "~/.zshrc fehlt – Setup abgebrochen." >&2
  exit 1
fi

###############################################################################
# 3) Hostname / SMB
###############################################################################
sudo scutil --set HostName Macintosh
sudo scutil --set LocalHostName Macintosh
sudo scutil --set ComputerName Macintosh
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string Macintosh

###############################################################################
# 4) Safari: Dev und Sicherheit
###############################################################################
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari WebKitDeveloperExtras -bool true
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

###############################################################################
# 5) Firewall (Grundzustand an)
###############################################################################
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

###############################################################################
# 6) Animationen/Key Repeat
###############################################################################
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

###############################################################################
# 7) Dialoge (Drucken/Speichern) & Tastaturnavigation
###############################################################################
defaults write NSGlobalDomain AppleKeyboardUIMode -int 2
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

###############################################################################
# 8) Finder
###############################################################################
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"   # Listenansicht
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

###############################################################################
# 9) Screenshots
###############################################################################
defaults write com.apple.screencapture location -string "${HOME}/Downloads"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true
defaults write com.apple.screencapture show-thumbnail -bool true
defaults write com.apple.screencapture include-date -bool true

###############################################################################
# 10) Locale & ISO-nahe Formate
###############################################################################
defaults write NSGlobalDomain AppleLocale -string "de_DK@currency=EUR"
defaults write NSGlobalDomain AppleFirstWeekday -dict gregorian 2
defaults write NSGlobalDomain AppleICUDateFormatStrings -dict \
  "1" "yyyy-MM-dd HH:mm" \
  "2" "yyyy-MM-dd HH:mm:ss" \
  "3" "yyyy-MM-dd HH:mm:ss" \
  "4" "yyyy-MM-dd HH:mm:ss"

###############################################################################
# 11) Dock/Launchpad
###############################################################################
defaults write com.apple.dock springboard-columns -int 10
defaults write com.apple.dock springboard-rows -int 10
defaults write com.apple.dock springboard-hide-duration -int 0
defaults write com.apple.dock springboard-show-duration -int 0
defaults write com.apple.dock mineffect -string "scale"

###############################################################################
# Prozesse neu starten (tolerant)
###############################################################################
killall Dock || true
killall Finder || true
killall SystemUIServer || true

###############################################################################
# 12) Energie: geplanter Shutdown
###############################################################################
sudo pmset repeat shutdown MTWRFSU 01:30:00

###############################################################################
# 13) Xcode Command Line Tools (GUI, mit Warten)
###############################################################################
read -p "Möchtest du Xcode (Command Line Tools) installieren? (y/n): " antwort1
if [[ "$antwort1" != "y" && "$antwort1" != "Y" ]]; then
  exit 1
fi
echo "Warte auf Xcode-Installation... GUI bestätigen!"
xcode-select --install || true
count=0
until xcode-select -p &>/dev/null; do
  sleep 5
  ((count+=5))
  if ((count >= 1800)); then
    echo "Fehler: CLT wurden nicht installiert (Timeout)." >&2
    exit 1
  fi
done

###############################################################################
# 14) Homebrew (non-interaktiv) + Pakete
###############################################################################
read -p "Möchtest du Homebrew installieren? (y/n): " antwort2
if [[ "$antwort2" != "y" && "$antwort2" != "Y" ]]; then
  exit 1
fi
export NONINTERACTIVE=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Brew-Umgebung laden (Apple Silicon)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew install bash nano grep wget rsync tree nmap smartmontools cowsay fortune

# nano-Syntax-Highlighting einmalig aktivieren
touch "$HOME/.nanorc"
if ! grep -Fq '/opt/homebrew/share/nano/*.nanorc' "$HOME/.nanorc"; then
  echo 'include "/opt/homebrew/share/nano/*.nanorc"' >> "$HOME/.nanorc"
fi

brew install --cask font-fira-code font-montserrat font-league-spartan font-jetbrains-mono

echo "Fertig. Neustart empfohlen."