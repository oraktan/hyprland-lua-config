#!/usr/bin/env bash

options=(
  "Cok Yavas      | -1.0"
  "Yavas          | -0.5"
  "Biraz Yavas    | -0.25"
  "Normal         | 0.0"
  "Biraz Hizli    | 0.25"
  "Hizli          | 0.5"
  "Cok Hizli      | 0.75"
  "Maksimum       | 1.0"
  "Ozel Deger Gir"
)

choice=$(
  printf '%s\n' "${options[@]}" |
    rofi -dmenu -i -p "Mouse Sensitivity"
)

[[ -n "$choice" ]] || exit 0

if [[ "$choice" == "Ozel Deger Gir" ]]; then
  value=$(
    rofi -dmenu -p "Deger (-1.0 / 1.0)" \
      -mesg "Ornek: 0.35"
  )
else
  value="${choice##*| }"
fi

[[ -n "$value" ]] || exit 0

# Sadece -1 ile 1 arasindaki ondalik sayilar
if ! [[ "$value" =~ ^-?(0(\.[0-9]+)?|1(\.0+)?)$ ]]; then
  notify-send "Mouse" "Gecersiz deger: $value"
  exit 1
fi

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Yeni Lua tabanli Hyprland
if [[ -f "$CONFIG_HOME/hypr/hyprland.lua" ]]; then
  result=$(
    hyprctl eval \
      "hl.config({ input = { sensitivity = $value } })" \
      2>&1
  )
else
  # Eski .conf tabanli Hyprland
  result=$(
    hyprctl keyword input:sensitivity "$value" 2>&1
  )
fi

if [[ $? -eq 0 && "$result" != *"error"* ]]; then
  notify-send "Mouse Sensitivity" \
    "Hassasiyet: $value"
else
  notify-send -u critical "Mouse Hatasi" "$result"
  exit 1
fi
