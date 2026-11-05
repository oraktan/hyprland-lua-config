
#!/usr/bin/env bash

SCRIPTS_DIR="$HOME/.config/hypr/scripts"

menu() {
    printf '%s\n' \
        "󰖩  Ağ ve Bağlantılar" \
        "󰕾  Ses Yönetimi" \
        "󰍹  Ekran ve Pencereler" \
        "󰏘  Tema ve Görünüm" \
        "󰀻  Uygulamalar" \
        "󰒓  Sistem Araçları" \
        "󰋊  Dosyalar ve Diskler" \
        "󰐥  Güç Yönetimi" \
        "󰑓  Tüm Scriptler"
}

choose() {
    rofi -dmenu -i -p "$1"
}

run_script() {
    local file="$SCRIPTS_DIR/$1"

    if [[ -f "$file" ]]; then
        bash "$file"
    else
        notify-send "Rofi Control Center" \
            "Script bulunamadı: $1"
    fi
}

main() {
    local selection
    selection=$(menu | choose "Control Center") || exit 0

    case "$selection" in
        *"Ağ ve Bağlantılar")
            run_script "network.sh"
            ;;
        *"Ses Yönetimi")
            run_script "Volume.sh"
            ;;
        *"Ekran ve Pencereler")
            run_script "window-switcher.sh"
            ;;
        *"Tema ve Görünüm")
            run_script "RofiThemeSelector.sh"
            ;;
        *"Uygulamalar")
            rofi -show drun
            ;;
        *"Sistem Araçları")
            run_script "Kool_Quick_Settings.sh"
            ;;
        *"Dosyalar ve Diskler")
            run_script "filesearch.sh"
            ;;
        *"Güç Yönetimi")
            run_script "Battery.sh"
            ;;
        *"Tüm Scriptler")
            all_scripts
            ;;
    esac
}

all_scripts() {
    local selected
    local -a files=()

    while IFS= read -r -d '' file; do
        files+=("$file")
    done < <(
        find "$SCRIPTS_DIR" -maxdepth 1 \
            -type f -name "*.sh" -print0
    )

    ((${#files[@]})) || {
        notify-send "Rofi" "Script bulunamadı"
        return
    }

    selected=$(
        printf '%s\n' "${files[@]##*/}" |
        sort |
        choose "Script Seç"
    ) || return

    [[ -n "$selected" ]] || return

    run_script "$selected"
}

main

