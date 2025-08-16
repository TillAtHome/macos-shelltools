#!/usr/bin/env bash
# Finder/Dock/Screenshot Defaults: Backup + Reset + Apply (macOS 15+)


set -euo pipefail

TS="$(date +%Y%m%d-%H%M%S)"
BK="${HOME}/Desktop/DefaultsBackup-$TS"
PREF="${HOME}/Library/Preferences"
CACHE="${HOME}/Library/Caches"
SAVED="${HOME}/Library/Saved Application State"

echo "→ Backup nach $BK"
mkdir -p "$BK"
cp -v "$PREF/com.apple.finder.plist" "$BK"/ 2>/dev/null || true
cp -v "$PREF/com.apple.sidebarlists.plist" "$BK"/ 2>/dev/null || true
cp -v "$PREF/com.apple.dock.plist" "$BK"/ 2>/dev/null || true
cp -v "$PREF/com.apple.screencapture.plist" "$BK"/ 2>/dev/null || true

echo "→ Finder/Dock/SystemUIServer stoppen"
killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true
killall -u "$USER" cfprefsd 2>/dev/null || true

echo "→ Preferences löschen (HARD reset)"
rm -f "$PREF/com.apple.finder.plist"
rm -f "$PREF/com.apple.sidebarlists.plist"

echo "→ Caches/States säubern"
rm -rf "$CACHE/com.apple.finder" 2>/dev/null || true
rm -rf "$SAVED/com.apple.finder.savedState" 2>/dev/null || true

###############################################################################
# DEINE DEFAULTS (leicht ergänzt/optimiert)
###############################################################################

# 1) Animationen/Key Repeat
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# Empfohlen: Hold-to-Repeat statt Akzentmenü
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# 2) Dialoge (Drucken/Speichern) & Tastaturnavigation
defaults write NSGlobalDomain AppleKeyboardUIMode -int 2
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# 3) Finder
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"   # Listenansicht
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# Global statt nur Finder: Fenster NICHT wiederherstellen
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

# 4) Screenshots
defaults write com.apple.screencapture location -string "${HOME}/Downloads"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true
defaults write com.apple.screencapture show-thumbnail -bool true
defaults write com.apple.screencapture include-date -bool true

# 5) Locale & ISO-nahe Formate
defaults write NSGlobalDomain AppleLocale -string "de_DK@currency=EUR"
defaults write NSGlobalDomain AppleFirstWeekday -dict gregorian 2
defaults write NSGlobalDomain AppleICUDateFormatStrings -dict \
  "1" "yyyy-MM-dd HH:mm" \
  "2" "yyyy-MM-dd HH:mm:ss" \
  "3" "yyyy-MM-dd HH:mm:ss" \
  "4" "yyyy-MM-dd HH:mm:ss"

# 6) Dock/Launchpad
defaults write com.apple.dock springboard-columns -int 10
defaults write com.apple.dock springboard-rows -int 10
defaults write com.apple.dock springboard-hide-duration -int 0
defaults write com.apple.dock springboard-show-duration -int 0
defaults write com.apple.dock mineffect -string "scale"

###############################################################################

echo "→ Prefsd neu starten & Dienste anwerfen"
killall -u "$USER" cfprefsd 2>/dev/null || true
open -ga Finder
killall Dock 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo "✓ Fertig. Backup: $BK"
