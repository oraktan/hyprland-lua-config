#!/usr/bin/env bash

# 1. Klasörleri ara ve seç (fd yüklü değilse find kullanabilirsin)
selected=$(fd --type d --max-depth 3 --base-directory "$HOME" | \
    rofi -dmenu -i -p "󱞞 Yazi ile Aç:" \
    -theme-str 'listview {columns: 1; lines: 10;}' \
    -theme-str 'window {width: 50%;}')

# 2. Eğer bir klasör seçildiyse
if [ -n "$selected" ]; then
    # Ghostty terminalini aç ve içinde Yazi'yi seçilen klasörde başlat
    # $HOME/$selected tam yolu temsil eder
    ghostty -e yazi "$HOME/$selected"
fi
