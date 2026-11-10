#!/bin/bash

PIN_FILE="$HOME/.config/rofi/cliphist_pins"
SNIP_FILE="$HOME/.config/rofi/snippet.txt"
ROFI_CFG="$HOME/.config/rofi/config.rasi"
mkdir -p "$(dirname "$PIN_FILE")"
touch "$PIN_FILE" "$SNIP_FILE"

# Mod: argüman "snip" ise snippet menüsü, yoksa pano menüsü
MODE="hist"
[ "$1" = "snip" ] && MODE="snip"

# --- FONKSİYONLAR ---
parse_snippets() {
    awk '
        /^[[:space:]]*(#|$)/ { next }
        {
            i = index($0, ":")
            if (i < 2) next
            k = substr($0, 1, i-1)
            v = substr($0, i+1)
            gsub(/^[ \t]+|[ \t]+$/, "", k)
            sub(/^[ \t]+/, "", v)
            if (k != "") print k "\t" v
        }' "$SNIP_FILE"
}

expand_snippet() {
    local v
    v=$(parse_snippets | awk -F'\t' -v k="$1" '$1==k { sub(/^[^\t]*\t/, ""); print; exit }')
    printf '%b' "$v"
}

delete_snippet() {
    awk -v k="$1" '
        {
            i = index($0, ":")
            kk = substr($0, 1, i-1)
            gsub(/^[ \t]+|[ \t]+$/, "", kk)
            if (i >= 2 && kk == k) next
            print
        }' "$SNIP_FILE" > "$SNIP_FILE.tmp" && mv "$SNIP_FILE.tmp" "$SNIP_FILE"
}

# Metni tek satıra kodla: \ -> \\ ve satır sonu -> \n (pin ve snippet için)
encode_line() {
    sed ':a;N;$!ba;s/\\/\\\\/g;s/\n/\\n/g'
}

# Pin sil (grep boş sonuçta 1 döndürdüğü için && kullanmıyoruz)
remove_pin() {
    grep -Fxv -- "$1" "$PIN_FILE" > "$PIN_FILE.tmp"
    mv "$PIN_FILE.tmp" "$PIN_FILE"
}

get_text() {
    case "$item_type" in
        snippet) expand_snippet "$clean_item" ;;
        pin)     printf '%b' "$clean_item" ;;
        *)       echo "$clean_item" | cliphist decode ;;
    esac
}

strip_num() {
    sed -E 's/^[[:space:]]*[0-9]+\.[[:space:]]//'
}

# --- MENÜ İÇERİĞİ ---
WIPE_LABEL="󰆴 TÜM GEÇMİŞİ SİL"
SNIPS=$(parse_snippets | awk -F'\t' '{ k=$1; sub(/^[^\t]*\t/, ""); print "󰌌 " k " │ " $0 }')
HISTORY_LIST=""

if [ "$MODE" = "snip" ]; then
    if [ -z "$SNIPS" ]; then
        notify-send "Clipboard" "Snippet yok. $SNIP_FILE dosyasına 'isim: değer' ekle"
        exit
    fi
    MENU_OPTIONS=$(echo "$SNIPS" | nl -w1 -s'. ')
    PROMPT="󰌌 Snippet"
    MESG="Enter/Tık: Yapıştır | 1-9: Hızlı Seç | Alt+s: Telefona | Alt+d: Sil | Alt+t: Pano geçmişi"
else
    PINNED=$(grep -v '^$' "$PIN_FILE" | sed 's/^/󰐃 [PİN] /')
    HISTORY_LIST=$(cliphist list)
    HISTORY_WITH_NUMS=$(echo "$HISTORY_LIST" | nl -w1 -s'. ')
    MENU_OPTIONS=$(
        [ -n "$PINNED" ] && echo "$PINNED"
        [ -n "$HISTORY_LIST" ] && echo "$HISTORY_WITH_NUMS"
        echo "$WIPE_LABEL"
    )
    PROMPT="📋 Clipboard"
    MESG="Alt+p: Pin | Alt+d: Sil | Alt+s: Telefona | Alt+n: Snippet yap | Alt+t: Snippet'ler | 1-9: Hızlı Seç"
    if [ -z "$HISTORY_LIST" ]; then
        MESG="⚠ Geçmiş boş: 'wl-paste --watch cliphist store' çalışmıyor olabilir | $MESG"
    fi
fi

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
# kb-custom-N => çıkış kodu 9+N
# 10=pin | 11=sil | 12..20=1-9 | 21=telefon | 22=snippet yap | 23=mod değiştir
selected=$(echo "$MENU_OPTIONS" | rofi -dmenu -i \
    -p "$PROMPT" \
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
    -kb-custom-12 "Alt+s" \
    -kb-custom-13 "Alt+n" \
    -kb-custom-14 "Alt+t" \
    -mesg "$MESG" \
    -config "$ROFI_CFG" \
    -hover-select -me-select-entry '' -me-accept-entry MousePrimary)

EXIT_CODE=$?

# Hiçbir şey seçilmediyse ve tuşa basılmadıysa çık
[ -z "$selected" ] && [ "$EXIT_CODE" -lt 12 ] && exit

# --- MOD DEĞİŞTİR (Alt+t) ---
if [ "$EXIT_CODE" -eq 23 ]; then
    if [ "$MODE" = "snip" ]; then
        exec "$0"
    else
        exec "$0" snip
    fi
fi

# --- HIZLI SEÇİM MANTIĞI (1-9 tuşları) ---
if [ "$EXIT_CODE" -ge 12 ] && [ "$EXIT_CODE" -le 20 ]; then
    ROW=$((EXIT_CODE - 11))
    if [ "$MODE" = "snip" ]; then
        selected=$(echo "$SNIPS" | sed -n "${ROW}p")
    else
        selected=$(echo "$HISTORY_LIST" | sed -n "${ROW}p")
    fi
fi

# Seçim boşsa (ör. o numarada öğe yoksa) çık
[ -z "$selected" ] && exit

# Snippet modunda satır numarasını temizle
[ "$MODE" = "snip" ] && selected=$(echo "$selected" | strip_num)

# --- TÜM GEÇMİŞİ SİL (onaylı) ---
if [ "$selected" = "$WIPE_LABEL" ]; then
    answer=$(printf 'Hayır\nEvet, sil' | rofi -dmenu -i -p "Geçmiş silinsin mi?" -config "$ROFI_CFG")
    if [ "$answer" = "Evet, sil" ]; then
        cliphist wipe
        notify-send "Clipboard" "Geçmiş temizlendi (pinler ve snippet'ler korundu)"
    fi
    exit
fi

# --- ÖĞE TÜRÜNÜ BELİRLE ---
item_type="history"
clean_item="$selected"

case "$selected" in
    "󰐃 [PİN] "*)
        item_type="pin"
        clean_item="${selected#"󰐃 [PİN] "}"
        ;;
    "󰌌 "*)
        item_type="snippet"
        key="${selected#"󰌌 "}"
        clean_item="${key%% │ *}"
        ;;
    *)
        clean_item=$(echo "$selected" | strip_num)
        ;;
esac

# --- PIN TOGGLE (Alt+p) ---
if [ "$EXIT_CODE" -eq 10 ]; then
    case "$item_type" in
        snippet)
            notify-send "Clipboard" "Snippet zaten kalıcı"
            ;;
        pin)
            remove_pin "$clean_item"
            notify-send "Clipboard" "Pin kaldırıldı"
            ;;
        *)
            if echo "$clean_item" | grep -q "binary data"; then
                notify-send "Clipboard" "Görseller pinlenemez"
                exit
            fi
            # Çözülmüş gerçek metni tek satıra kodlayıp sakla
            pin_line=$(get_text | encode_line)
            [ -z "$pin_line" ] && exit
            if grep -Fxq -- "$pin_line" "$PIN_FILE"; then
                remove_pin "$pin_line"
                notify-send "Clipboard" "Pin kaldırıldı"
            else
                echo "$pin_line" >> "$PIN_FILE"
                notify-send "Clipboard" "Pinlendi"
            fi
            ;;
    esac
    exit
fi

# --- DELETE ITEM (Alt+d) ---
if [ "$EXIT_CODE" -eq 11 ]; then
    if [ "$item_type" = "snippet" ]; then
        delete_snippet "$clean_item"
        notify-send "Clipboard" "Snippet silindi: $clean_item"
    elif [ "$item_type" = "pin" ]; then
        remove_pin "$clean_item"
        notify-send "Clipboard" "Pin silindi"
    else
        echo "$clean_item" | cliphist delete
        notify-send "Clipboard" "Silindi"
    fi
    exit
fi

# --- TELEFONA GÖNDER (Alt+s) ---
if [ "$EXIT_CODE" -eq 21 ]; then
    [ -z "$clean_item" ] && exit

    if [ "$item_type" = "history" ] && echo "$clean_item" | grep -q "binary data"; then
        notify-send "Clipboard" "Görseller bu yöntemle gönderilemez"
        exit
    fi

    send_text=$(get_text)

    devices=$(kdeconnect-cli -a --id-name-only 2>/dev/null)
    if [ -z "$devices" ]; then
        notify-send "Clipboard" "Bağlı telefon bulunamadı"
        exit
    fi

    if [ "$(echo "$devices" | wc -l)" -eq 1 ]; then
        device_line="$devices"
    else
        device_line=$(echo "$devices" | rofi -dmenu -i -p "📱 Cihaz" -config "$ROFI_CFG")
        [ -z "$device_line" ] && exit
    fi

    device_id=${device_line%% *}
    device_name=${device_line#* }

    if kdeconnect-cli -d "$device_id" --share-text "$send_text"; then
        notify-send "Clipboard" "Telefona gönderildi: $device_name"
    else
        notify-send "Clipboard" "Gönderilemedi"
    fi
    exit
fi

# --- SNIPPET YAP (Alt+n) ---
if [ "$EXIT_CODE" -eq 22 ]; then
    [ -z "$clean_item" ] && exit

    if [ "$item_type" = "snippet" ]; then
        notify-send "Clipboard" "Bu zaten bir snippet"
        exit
    fi
    if [ "$item_type" = "history" ] && echo "$clean_item" | grep -q "binary data"; then
        notify-send "Clipboard" "Görseller snippet yapılamaz"
        exit
    fi

    text=$(get_text)

    key=$(rofi -dmenu -p "󰌌 Snippet adı (örn: imail)" -config "$ROFI_CFG" < /dev/null)
    key=${key//[[:space:]]/}
    key=${key//:/}
    [ -z "$key" ] && exit

    value=$(printf '%s' "$text" | encode_line)

    delete_snippet "$key"
    echo "$key: $value" >> "$SNIP_FILE"

    notify-send "Clipboard" "Snippet kaydedildi: $key"
    exit
fi

# --- COPY & PASTE ---
case "$item_type" in
    history)
        # Doğrudan boru: görseller ve satır sonları bozulmaz
        echo "$clean_item" | cliphist decode | wl-copy
        ;;
    snippet)
        text=$(get_text)
        printf '%s' "$text" | wl-copy --sensitive 2>/dev/null || printf '%s' "$text" | wl-copy
        ;;
    pin)
        get_text | wl-copy
        ;;
esac

sleep 0.2

# Terminallerde yapıştırma Ctrl+Shift+V'dir
class=$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // ""')
case "$class" in
    *kitty*|*ghostty*|*foot*|*[Aa]lacritty*|*wezterm*)
        wtype -M ctrl -M shift v -m shift -m ctrl
        ;;
    *)
        wtype -M ctrl v -m ctrl
        ;;
esac
