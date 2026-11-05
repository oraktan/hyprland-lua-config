#!/usr/bin/env bash

# Taner Orak - Hyprland Screenshot Script (Instant Clipboard & Swappy)

dir="$(xdg-user-dir PICTURES)/Screenshots"
iDIR="$HOME/.config/swaync/icons"
sDIR="$HOME/.config/hypr/scripts"

mkdir -p "$dir"

notify_and_sound() {
    local file_path=$1
    if [[ -f "$file_path" && -s "$file_path" ]]; then
        wl-copy --type image/png < "$file_path"
        
        if [[ -f "${sDIR}/Sounds.sh" ]]; then
            "${sDIR}/Sounds.sh" --screenshot
        fi
        
        resp=$(notify-send -t 10000 -A action1="Aç" -A action2="Sil" \
            -i "$iDIR/picture.png" "Ekran Görüntüsü" "Kaydedildi ve Panoya Kopyalandı.")
        
        case "$resp" in
            action1) xdg-open "$file_path" ;;
            action2) rm "$file_path" ;;
        esac
    else
        if [[ -f "$file_path" ]]; then rm "$file_path"; fi
        notify-send -u low -i "$iDIR/error.png" "İptal Edildi" "Ekran görüntüsü alınmadı."
    fi
}

case "$1" in
    --now)
        file="${dir}/screenshot_$(date +%Y%m%d_%H%M%S).png"
        hyprshot -m output -o "$dir" -f "$(basename "$file")" --silent
        notify_and_sound "$file"
        ;;
    --area)
        file="${dir}/screenshot_$(date +%Y%m%d_%H%M%S).png"
        hyprshot -m region -o "$dir" -f "$(basename "$file")" --silent
        notify_and_sound "$file"
        ;;
    --win)
        file="${dir}/screenshot_$(date +%Y%m%d_%H%M%S).png"
        hyprshot -m window -o "$dir" -f "$(basename "$file")" --silent
        notify_and_sound "$file"
        ;;
    --swappy)
    tmp_file="/tmp/swappy_buffer.png"
    out_file="/tmp/swappy_out.png"
    rm -f "$tmp_file" "$out_file"

    if grim -g "$(slurp)" "$tmp_file"; then
        # 1. Anında panoya kopyala (tipi belirterek)
        wl-copy -t image/png < "$tmp_file"

        # 2. Swappy'yi aç; sadece kaydedilirse (Ctrl+S) çıktı dosyası oluşur
        swappy -f "$tmp_file" -o "$out_file"

        # 3. Düzenlenip kaydedildiyse panoyu güncelle, aksi halde dokunma
        if [[ -s "$out_file" ]]; then
            wl-copy -t image/png < "$out_file"
        fi

        rm -f "$tmp_file" "$out_file"
    else
        notify-send -u low "İptal" "Seçim yapılmadı."
    fi
    ;; 
      *)
        echo "Kullanım: $0 {--now|--area|--win|--swappy}"
        ;;
esac
