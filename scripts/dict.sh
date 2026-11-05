#!/bin/bash

# Sözlük dosyasının yolu
DICT_FILE="$HOME/Documents/dict.txt"

# Dosya yoksa uyarı ver ve çık
if [[ ! -f "$DICT_FILE" ]]; then
    notify-send "Hata" "Sözlük dosyası bulunamadı: $DICT_FILE"
    exit 1
fi

# Dosyayı oku ve Rofi menüsünde göster
# (Boş satırları görmezden gelir)
choice=$(grep -v '^$' "$DICT_FILE" | rofi -dmenu -p "Sözlük:")

# Eğer bir seçim yapıldıysa
if [[ -n "$choice" ]]; then
    # "|" işaretinden sonrasını al ve boşlukları temizle
    result=$(echo "$choice" | cut -d'|' -f2- | xargs)
    
    # Panoya kopyala
    echo -n "$result" | wl-copy
    
    # Bildirim gönder
    notify-send "Kopyalandı" "$result"
    
    # İsteğe bağlı: Otomatik yapıştır (wtype yüklüyse)
    # sleep 0.2 && wtype "$result"
fi
# ... (önceki kodlar aynı)

if [[ -n "$choice" ]]; then
    result=$(echo "$choice" | cut -d'|' -f2- | xargs)
    
    # Önce panoya kopyala
    echo -n "$result" | wl-copy
    
    # Seçim ekranı kapandıktan hemen sonra aktif pencereye yazdır
    # (0.2 saniyelik gecikme, menünün tamamen kapanması için önemlidir)
    sleep 0.2 && wtype "$result"
    
    notify-send "Sözlük" "Kopyalandı ve Yazdırıldı: $result"
fi
