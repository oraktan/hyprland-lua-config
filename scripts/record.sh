#!/bin/bash

VIDEO_DIR="$HOME/Videos"
mkdir -p "$VIDEO_DIR"

if pgrep -x wf-recorder > /dev/null; then
    pkill -INT wf-recorder
    notify-send "Kayıt Durduruldu" "Video işleniyor, lütfen bekleyin..."

    # wf-recorder'ın dosyayı tamamen kapatması için 1-2 saniye bekle
    sleep 2

    # Son kaydı bul
    LAST_VIDEO=$(ls -t "$VIDEO_DIR"/*.mkv 2>/dev/null | head -n1)

    if [ -n "$LAST_VIDEO" ]; then
        OUTPUT="${LAST_VIDEO%.mkv}_wa.mp4"

        # "vf scale" filtresi eklendi: Genişlik ve yükseklik değerlerini çift sayıya zorlar.
        # WhatsApp tek sayılı piksel çözünürlüklerini (örn: 1081x1920) kesinlikle kabul etmez.
        ffmpeg -i "$LAST_VIDEO" \
            -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
            -c:v libx264 -pix_fmt yuv420p -preset veryfast -crf 23 \
            -c:a aac -b:a 128k \
            -y "$OUTPUT" # Eğer aynı isimde dosya varsa üzerine yazması için -y eklendi

        notify-send "Hazır 🎉" "WhatsApp uyumlu video oluşturuldu"
    fi
else
    AREA=$(slurp)
    # Kullanıcı seçimi iptal ederse çık
    [ -z "$AREA" ] && exit 1

    FILE="$VIDEO_DIR/$(date +%Y%m%d_%H%M%S).mkv"

    notify-send "Kayıt Başladı" "Seçilen bölge kaydediliyor..."

    # Arka planda çalışması için sonuna & eklemiyoruz çünkü durdurma tetiklemeli çalışıyor
    wf-recorder -g "$AREA" -f "$FILE"
fi
