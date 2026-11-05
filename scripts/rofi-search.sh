#!/usr/bin/env bash

# 1. Dosyayı seç (Tek sütun, 10 satır)
selected=$(rg --files --hidden --glob '!.git/*' "$HOME" | \
    sed "s|$HOME/||" | \
    rofi -dmenu -i -p "󰉋 Neovim ile Aç:" \
    -theme-str 'listview {columns: 1; lines: 10;}' \
    -theme-str 'window {width: 50%;}')

# 2. Eğer seçim yapıldıysa, yeni bir terminalde nvim çalıştır
if [ -n "$selected" ]; then
    # Kullandığın terminale göre burayı güncelle:
    # Eğer Ghostty kullanıyorsan: ghostty -e nvim "$HOME/$selected"
    # Eğer Alacritty kullanıyorsan: alacritty -e nvim "$HOME/$selected"
    # Genel olarak çoğu terminalde (kitty, foot vb.) -e parametresi çalışır:
    ghostty -e nvim "$HOME/$selected"
fi
