#!/usr/bin/env bash

set -u

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$1" "$2"
    else
        printf '%s: %s\n' "$1" "$2"
    fi
}

for cmd in hyprctl rofi awk; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        notify "Mouse Hatasi" "$cmd bulunamadi"
        exit 1
    fi
done

# Hyprland'deki mevcut hassasiyeti oku.
current="$(
    hyprctl getoption input:sensitivity 2>/dev/null |
    awk '/float:/ {printf "%+.2f", $2; exit}'
)"
current="${current:-Bilinmiyor}"

# -1.00 ile +1.00 arasinda 0.01 adimlar.
options="$(
    LC_ALL=C awk 'BEGIN {
        for (i = -100; i <= 100; i++)
            printf "%+.2f\n", i / 100
    }'
)"

choice="$(
    {
        printf 'Ozel Deger Gir\n'
        printf '%s\n' "$options"
    } | rofi -dmenu -i \
        -p "Mouse: $current" \
        -mesg "0.01 kademe | -1.00 ile +1.00"
)"

[[ -n "$choice" ]] || exit 0

if [[ "$choice" == "Ozel Deger Gir" ]]; then
    value="$(
        rofi -dmenu \
            -p "Hassasiyet" \
            -mesg "Ornek: 0.375 veya -0.42" </dev/null
    )"
else
    value="$choice"
fi

[[ -n "$value" ]] || exit 0

# Virgullu ondalik degerleri destekle.
value="${value/,/.}"

# Gecerli sayi mi?
if ! [[ "$value" =~ ^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)$ ]]; then
    notify "Mouse Hatasi" "Gecersiz deger: $value"
    exit 1
fi

# -1 ile +1 arasinda mi?
if ! LC_ALL=C awk -v n="$value" \
    'BEGIN {exit !(n >= -1 && n <= 1)}'; then
    notify "Mouse Hatasi" "Deger -1 ile +1 arasinda olmali"
    exit 1
fi

# Hyprland 0.57 Lua API ile uygula.
result="$(
    hyprctl eval \
        "hl.config({ input = { sensitivity = $value } })" 2>&1
)"
status=$?

if [[ "$status" -ne 0 || "$result" != "ok" ]]; then
    notify "Mouse Hatasi" "$result"
    exit 1
fi

# Gercekten uygulandigini kontrol et.
actual="$(
    hyprctl getoption input:sensitivity 2>/dev/null |
    awk '/float:/ {print $2; exit}'
)"

if LC_ALL=C awk -v a="$actual" -v b="$value" \
    'BEGIN {d=a-b; if(d<0)d=-d; exit !(d<0.00001)}'; then
    notify "Mouse Sensitivity" "Hassasiyet: $value"
else
    notify "Mouse Hatasi" "Deger dogrulanamadi: $actual"
    exit 1
fi
