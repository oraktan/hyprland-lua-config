# Hyprland Lua Configuration

Fedora 44 ve Hyprland 0.57 için modüler Lua yapılandırması.

## İçindekiler

1. [Ana yapılandırma](#1-ana-yapılandırma)
2. [Monitör ayarları](#2-monitör-ayarları)
3. [Mouse ve klavye](#3-mouse-ve-klavye)
4. [Pencere görünümü](#4-pencere-görünümü)
5. [Animasyonlar](#5-animasyonlar)
6. [Klavye kısayolları](#6-klavye-kısayolları)
7. [Pencere kuralları](#7-pencere-kuralları)
8. [Otomatik başlatma](#8-otomatik-başlatma)
9. [Genel sistem ayarları](#9-genel-sistem-ayarları)
10. [Yardımcı scriptler](#10-yardımcı-scriptler)
11. [Değişiklikleri uygulama](#11-değişiklikleri-uygulama)
12. [GitHub ve yedekleme](#12-github-ve-yedekleme)

## 1. Ana yapılandırma

**Dosya:** `hyprland.lua`

Diğer Lua modüllerini yükleyen ana dosyadır.

Modül eklemek veya yükleme sırasını değiştirmek için kullanılır.

## 2. Monitör ayarları

**Dosya:** `lua/monitors.lua`

- Monitör çözünürlüğü
- Yenileme hızı
- Ekran konumları
- Yatay ve dikey kullanım
- Monitörlere özel workspace atamaları

## 3. Mouse ve klavye

**Dosya:** `lua/input.lua`

- Mouse sensitivity
- Klavye düzeni
- Touchpad davranışı
- Giriş aygıtları

Mouse hassasiyeti örneği:

    sensitivity = -0.50,

Bu satır mevcut `input` tablosunun içine yazılır.

## 4. Pencere görünümü

**Dosya:** `lua/appearance.lua`

- `gaps_in`: Pencereler arası boşluk
- `gaps_out`: Ekran kenarı boşluğu
- `border_size`: Kenarlık kalınlığı
- `col.active_border`: Aktif pencere rengi
- `col.inactive_border`: Pasif pencere rengi
- Yuvarlatılmış köşeler
- Opaklık ve diğer görünüm ayarları

## 5. Animasyonlar

**Dosya:** `lua/animations.lua`

Pencere açma, kapama, taşıma ve workspace
geçiş animasyonlarını yönetir.

## 6. Klavye kısayolları

**Dosya:** `lua/keybinds.lua`

- Numpad 0–9: Workspace seçimi
- SUPER + sayı: Workspace seçimi
- SUPER + F1–F10: Aktif pencereyi workspace'e taşıma
- SUPER + SHIFT + sayı: Pencere taşıma
- SUPER + CTRL + sayı: Pencereyi takip etmeden taşıma
- Uygulama başlatma kısayolları

Diğer kısayollar için dosyanın kendisine bakın.

## 7. Pencere kuralları

**Dosya:** `lua/windowrules.lua`

Uygulamaların hangi workspace'te açılacağını
ve pencere davranışlarını yönetir.

Örnekler:
- Firefox profilleri: Workspace 1–4
- Thunderbird: Workspace 5
- Ghostty: Workspace 6
- LibreOffice: Workspace 7
- Okular: Workspace 8
- Telegram: Workspace 9

## 8. Otomatik başlatma

**Dosya:** `lua/autostart.lua`

Hyprland oturumu başladığında çalıştırılacak
uygulamalar burada tanımlanır.

Örnekler:
- Waybar
- nm-applet
- blueman-applet

## 9. Genel sistem ayarları

**Dosya:** `lua/core.lua`

Hyprland'in genel davranışlarını yöneten ayarlar.

## 10. Yardımcı scriptler

**Klasör:** `scripts/`

Rofi menüleri ve yardımcı Bash scriptleri bulunur.

Önemli örnek:

`scripts/MouseSensitivity.sh`

Mouse hassasiyetini Rofi üzerinden 0.01'lik
kademelerle değiştirir.

Not: Script ile uygulanan değer oturumluk olabilir.
Kalıcı varsayılan değer `lua/input.lua` içinde tutulur.

## 11. Değişiklikleri uygulama

Lua sözdizimini kontrol et:

    find lua -name '*.lua' -exec luac -p {} \;
    luac -p hyprland.lua

Hyprland'i yeniden yükle:

    hyprctl reload

Yapılandırma hatalarını kontrol et:

    hyprctl configerrors

## 12. GitHub ve yedekleme

Repository:

https://github.com/oraktan/hyprland-lua-config

Değişiklikleri gönder:

    git add .
    git commit -m "Update Hyprland configuration"
    git push origin HEAD:main

GitHub yapılandırma dosyalarını saklar.

Tam sistem geri yükleme için ayrıca
sistem snapshot/yedekleme çözümü gerekir.
