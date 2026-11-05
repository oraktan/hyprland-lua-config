#!/bin/bash

PIN_FILE="$HOME/.config/rofi/cliphist_pins"
mkdir -p "$(dirname "$PIN_FILE")"
touch "$PIN_FILE"

# --- PIN + HISTORY ---
# Pinler (Hızlı seçim koduna dahil etmiyoruz, onlar en üstte sabit)
PINNED=$(sed 's/^/󰐃 [PİN] /' "$PIN_FILE")
# Geçmiş (Numaralı hali)
HISTORY_LIST=$(cliphist list)
HISTORY_WITH_NUMS=$(echo "$HISTORY_LIST" | nl -w1 -s'. ')

MENU_OPTIONS="󰆴 TÜM GEÇMİŞİ SİL\n$PINNED\n$HISTORY_WITH_NUMS"

# --- MOUSE ORTALA ---
(
    sleep 0.1
    MONITOR_INFO=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true)')
    WIDTH=$(echo "$MONITOR_INFO" | jq '.width')
    HEIGHT=$(echo "$MONITOR_INFO" | jq '.height')
    X=$(echo "$MONITOR_INFO" | jq '.x')
    Y=$(echo "$MONITOR_INFO" | jq '.y')
    CENTER_X=$((X + WIDTH / 2))
    CENTER_Y=$((Y + HEIGHT / 2))
    hyprctl dispatch movecursor $CENTER_X $CENTER_Y
) &

# --- ROFI ---
# kb-custom-3'ten itibaren 1, 2, 3 tuşlarını atıyoruz (Exit Code 12, 13, 14...)
selected=$(echo -e "$MENU_OPTIONS" | rofi -dmenu -i \
    -p "📋 Clipboard" \
    -kb-custom-1 "Alt+p" \
    -kb-custom-2 "Alt+d" \
    -kb-custom-3 "1" \
    -kb-custom-4 "2" \
    -kb-custom-5 "3" \
    -kb-custom-6 "4" \
    -kb-custom-7 "5" \
    -kb-custom-8 "6" \
    -kb-custom-9 "7" \
    -kb-custom-10 "8" \
    -kb-custom-11 "9" \
    -mesg "Alt+p: Pin | Alt+d: Sil | 1-9: Hızlı Seç & Yapıştır" \
    -config ~/.config/rofi/config.rasi \
    -hover-select -me-select-entry '' -me-accept-entry MousePrimary)

EXIT_CODE=$?

# Hiçbir şey seçilmediyse ve tuşa basılmadıysa çık
[ -z "$selected" ] && [ "$EXIT_CODE" -lt 12 ] && exit

# --- HIZLI SEÇİM MANTIĞI (1-9 tuşları) ---
# Eğer 1-9 arası bir tuşa basıldıysa (Exit Code 12-20 arası)
if [ "$EXIT_CODE" -ge 12 ] && [ "$EXIT_CODE" -le 20 ]; then
    ROW=$((EXIT_CODE - 11))
    # Listenin o satırındaki veriyi orijinal listeden çekiyoruz (numarasız halini)
    selected=$(echo "$HISTORY_LIST" | sed -n "${ROW}p")
fi

# --- TÜM GEÇMİŞİ SİL ---
if [ "$selected" = "󰆴 TÜM GEÇMİŞİ SİL" ]; then
    cliphist wipe
    > "$PIN_FILE"
    notify-send "Clipboard" "Geçmiş temizlendi!"
    exit
fi

# --- TEMİZLEME VE KONTROL ---
is_pinned=false
clean_item="$selected"

if echo "$selected" | grep -q "^󰐃 \[PİN\]"; then
    is_pinned=true
    clean_item="${selected#󰐃 [PİN] }"
else
    # Manuel seçimde (Enter ile) baştaki numarayı temizle
    clean_item=$(echo "$selected" | sed -E 's/^[[:space:]]*[0-9]+\.[[:space:]]//')
fi

# --- PIN TOGGLE (Alt+p) ---
if [ "$EXIT_CODE" -eq 10 ]; then
    if grep -Fxq "$clean_item" "$PIN_FILE"; then
        grep -Fxv "$clean_item" "$PIN_FILE" > "$PIN_FILE.tmp" && mv "$PIN_FILE.tmp" "$PIN_FILE"
        notify-send "Clipboard" "Pin kaldırıldı"
    else
        echo "$clean_item" >> "$PIN_FILE"
        notify-send "Clipboard" "Pinlendi"
    fi
    exit
fi

# --- DELETE ITEM (Alt+d) ---
if [ "$EXIT_CODE" -eq 11 ]; then
    echo "$clean_item" | cliphist delete
    notify-send "Clipboard" "Silindi"
    exit
fi

# --- COPY & PASTE ---
if [ "$is_pinned" = true ]; then
    echo -n "$clean_item" | wl-copy
else
    # En sağlam yöntem: seçilen satırı decode et
    echo "$clean_item" | cliphist decode | wl-copy
fi

# Otomatik yapıştır
sleep 0.2
wtype -M ctrl v -m ctrl
