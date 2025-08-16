#!/usr/bin/env bash
echo "Deleting Finder 'Go To' folder history..."

if defaults delete com.apple.finder GoToField &>/dev/null; then
    echo "GoToField gelöscht."
else
    echo "GoToField nicht vorhanden oder schon gelöscht."
fi

if defaults delete com.apple.finder GoToFieldHistory &>/dev/null; then
    echo "GoToFieldHistory gelöscht."
else
    echo "GoToFieldHistory nicht vorhanden oder schon gelöscht."
fi

sleep 1
killall Finder && echo "Finder neu gestartet."

echo "FERTIG!"
