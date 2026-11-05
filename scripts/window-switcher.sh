#!/bin/bash

# JSON üzerinden listeyi oluştur (Hata payı sıfır)
list=$(hyprctl clients -j | jq -r '.[] | "[\(.workspace.name)] \(.class) — \(.title)\u0000info\u001f\(.address)"')

# Rofi
selected=$(echo -e "$list" | rofi -dmenu -i -p "🪟 Window")

[[ -z "$selected" ]] && exit

# Adresi çek (Rofi info alanına attığımız değer)
addr=$(echo "$selected" | awk -F'\x1f' '{print $NF}')

hyprctl dispatch focuswindow "address:$addr"
