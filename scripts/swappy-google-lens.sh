#!/usr/bin/env bash

# Yalnızca Swappy aktifken çalış.
active_class=$(hyprctl activewindow -j | python3 -c \
  'import json,sys; print(json.load(sys.stdin).get("class",""))')

if [[ "${active_class,,}" != *swappy* ]]; then
    notify-send "Google Lens" "Önce Swappy penceresini aç"
    exit 1
fi

# Swappy'deki düzenlenmiş görüntüyü kopyala.
wtype -M ctrl -k c -m ctrl
sleep 0.5

# Panoda görsel varsa Lens'i aç.
if wl-paste --list-types | grep -q 'image/png'; then
    firefox --new-tab "https://www.google.com/?olud"
else
    notify-send "Google Lens" "Panoda PNG görüntüsü bulunamadı"
fi
