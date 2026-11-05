#!/usr/bin/env bash

# Rofi temasını seç (dosya yoksa standart temayı kullanır)
if [ -f "$HOME/.config/rofi/config-calc.rasi" ]; then
    rofi_theme="$HOME/.config/rofi/config-calc.rasi"
else
    rofi_theme="$HOME/.config/rofi/config.rasi"
fi

# Rofi zaten açıksa kapat
pkill rofi

while true; do
    # Kullanıcıdan giriş al
    # -p "Hesapla": Sol üstte görünür
    # -mesg: Sonucu bir alt satırda gri tonda gösterir
    user_input=$(rofi -dmenu \
        -config "$rofi_theme" \
        -p "󰪚 Hesapla" \
        -mesg "Sonuç: $calc_result")

    # Esc basılırsa veya boş bırakılırsa çık
    if [ $? -ne 0 ] || [ -z "$user_input" ]; then
        exit
    fi

    # HESAPLAMA MOTORU (qalc kullanıyoruz)
    # -t: Sadece sonucu verir (gereksiz yazıları siler)
    calc_result=$(qalc -t "$user_input" 2>/dev/null)

    # Eğer hesaplama başarılıysa
    if [ -n "$calc_result" ]; then
        # Sonucu panoya kopyala
        echo -n "$calc_result" | wl-copy
    else
        calc_result="Hata! Geçersiz işlem."
    fi
done
