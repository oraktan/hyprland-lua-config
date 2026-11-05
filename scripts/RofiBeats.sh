#!/usr/bin/env bash
# /* ---- 💫 MPV Integrated - Fedora & Hyprland 💫 ---- */ ##

mDIR="$HOME/Music/"
iDIR="$HOME/.config/swaync/icons"
rofi_theme="$HOME/.config/rofi/config-rofi-Beats.rasi"
rofi_theme_menu="$HOME/.config/rofi/config-rofi-Beats-menu.rasi"
music_list="$HOME/.config/rofi/online_music.list"

notification() {
    notify-send -u normal -i "$iDIR/music.png" "Music Player" "$@"
}

# Çalışan müzik süreçlerini temizle
stop_music() {
    pkill -x "mpv" > /dev/null 2>&1
    notification "Müzik Durduruldu"
}

play_local_music() {
    # Müzik dosyalarını bul (boşluklu dosya adları için güvenli yöntem)
    mapfile -t local_music < <(find -L "$mDIR" -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.wav" -o -iname "*.ogg" -o -iname "*.m4a" \))
    
    [[ ${#local_music[@]} -eq 0 ]] && { notification "Hata" "Müzik klasörü boş!"; exit 1; }

    filenames=()
    for file in "${local_music[@]}"; do filenames+=("$(basename "$file")"); done

    choice=$(printf "%s\n" "${filenames[@]}" | rofi -i -dmenu -config "$rofi_theme" -theme-str 'entry { placeholder: "🎵 MPV: Yerel Müzik Seç"; }')

    [[ -z "$choice" ]] && exit 1

    for ((i = 0; i < "${#filenames[@]}"; ++i)); do
        if [ "${filenames[$i]}" = "$choice" ]; then
            pkill -x "mpv" > /dev/null 2>&1
            # mpv ile arka planda sadece ses (no-video) çal
            mpv --no-video --msg-level=all=no "${local_music[$i]}" > /dev/null 2>&1 &
            notification "Şu an çalıyor:" "$choice"
            break
        fi
    done
}

play_online_music() {
    if [ ! -s "$music_list" ]; then
        notification "Hata" "Müzik listesi boş veya dosya yok!"
        exit 1
    fi

    choice=$(awk -F'|' '{print $1}' "$music_list" | sort | rofi -i -dmenu -config "$rofi_theme" -theme-str 'entry { placeholder: "🌐 MPV: Online/YouTube Seç"; }')
    [[ -z "$choice" ]] && exit 1
    link=$(awk -F'|' -v name="$choice" '$1 == name {print $2; exit}' "$music_list")

    pkill -x "mpv" > /dev/null 2>&1
    notification "Bağlanıyor..." "$choice"
    
    # MPV + yt-dlp entegrasyonu ile YouTube/Stream çalma
    mpv --no-video --ytdl-format="bestaudio" --cache=yes "$link" > /dev/null 2>&1 &
}

shuffle_music() {
    pkill -x "mpv" > /dev/null 2>&1
    notification "Karışık Çalma Başladı"
    # Tüm müzikleri mDIR içinden tara ve karıştırarak mpv'ye ver
    mpv --no-video --shuffle --playlist-start=random "$mDIR" > /dev/null 2>&1 &
}

user_choice=$(printf "%s\n" "Play from Online Stations" "Play from Music directory" "Shuffle Play from Music directory" "Stop Music Player" | rofi -dmenu -config "$rofi_theme_menu" -theme-str 'entry { placeholder: "🎧 Music Menu (mpv)"; }')

case "$user_choice" in
    "Play from Online Stations") play_online_music ;;
    "Play from Music directory") play_local_music ;;
    "Shuffle Play from Music directory") shuffle_music ;;
    "Stop Music Player") stop_music ;;
esac
