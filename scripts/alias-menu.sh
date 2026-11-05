#!/usr/bin/env bash
set -euo pipefail

pkill yad 2>/dev/null || true
pidof rofi >/dev/null && pkill rofi

ROFI_THEME="$HOME/.config/rofi/config-keybinds.rasi"
MSG="💻 Terminal Kısayolları ve Fonksiyonlar (Aramak için yazın)"

# Terminal Kısayollarının Temiz ve Açıklayıcı Listesi
LIST=$(cat << 'EOF'
vf — (Vim Find) Gizli dosyalar dahil arama yap ve Vim'de aç
cf — (Cd Find) Gizli klasörler dahil ara ve içine gir
fif — (Find in Files) Dosya içinde metin ara, o satıra git (rg+fzf)
f — Telescope tarzı dosya/klasör bulucu ve önizleyici
yy — [Dosya] İçeriğini panoya kopyala (Wayland/wl-copy)
pp — Panodaki metni terminale yapıştır/çıkar (xclip)
n — [Not/Boş] Hızlı not ekle (tarihli) veya notları listele
gitu — [Mesaj] Dotfiles reposunu tek tuşla commit ve push yap
iceaktar — bashrc dosyasını anında yeniden yükle (source)
edit — Alias dosyasını Vim ile düzenle
!! — Son girilen komutu 'sudo' ile çalıştır
gp / gd / gD — Pictures / Downloads / Documents klasörüne git
gh / gz / gn — Hyprland / Zsh / Notlar klasörüne git
g. / gy — Dotfiles / Yazi klasörüne git
ll / la / dir — Gelişmiş, renkli dosya listeleme komutları
maxdosya — Boyutu en büyük dosyaları bul ve sırala
duf — Klasör boyutlarını insan okunabilir şekilde listele
ramizle — RAM kullanımını canlı olarak (watch) izle
myip — Dış (Public) IP adresini ekrana yazdır
wifires / wifion / wifioff — WiFi adaptörünü kapat/aç/yeniden başlat
psg / pid / pkill — Süreçleri filtrele, bul ve öldür
ts — Timeshift ile Fedora tam sistem yedeği al
mp3indir — [URL] Youtube'dan sesi MP3 olarak indir
pyserve — Bulunduğun klasörde anında HTTP sunucusu başlat
mkcd — [Klasör] Klasörü oluştur ve hemen içine gir
c — [Dosya] Dosyaya anında çalıştırma (chmod +x) izni ver
indir — [Paket] Sudo dnf install ile hızlı paket kur
empty-trash — Çöp kutusunu tamamen boşalt
untar — [Arşiv] tar.gz arşivini dışa çıkart
EOF
)

# Listeyi Rofi'ye gönder
printf '%s\n' "$LIST" \
  | rofi -dmenu \
      -i \
      -matching fuzzy \
      -sorting-method fzf \
      -no-sort \
      -lines 20 \
      -width 70 \
      -p "💻 Bash Aliases" \
      -mesg "$MSG" \
      -config "$ROFI_THEME"
