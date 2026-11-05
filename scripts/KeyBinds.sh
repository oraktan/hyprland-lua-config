#!/usr/bin/env bash
set -euo pipefail

pkill yad 2>/dev/null || true
pidof rofi >/dev/null && pkill rofi

CONF_FILES=(
  "$HOME/.config/hypr/Keybinds.conf"
)

ROFI_THEME="$HOME/.config/rofi/config-keybinds.rasi"
MSG="🔍 Hyprland Keybinds (type to search)"

parse_binds() {
  awk '
  function trim(s){gsub(/^[ \t]+|[ \t]+$/,"",s); return s}

  /^[ \t]*bind/ {
    split($0, x, "=")
    if (length(x) < 2) next

    binder=trim(x[1])
    rhs=trim(x[2])

    n=split(rhs, a, /[ \t]*,[ \t]*/)
    if (n < 2) next

    mods=trim(a[1])
    key=trim(a[2])
    if (mods=="" || key=="") next

    gsub(/\$mainMod/, "SUPER", mods)
    gsub(/[ \t]+/, "+", mods)

    combo=mods "+" key

    if (binder ~ /^bindd/) {
      desc = (n>=3 ? trim(a[3]) : "")
      if (desc != "")
        print combo " — " desc
    } else {
      dispatcher = (n>=3 ? trim(a[3]) : "")
      params=""
      for (i=4;i<=n;i++) params=params" "trim(a[i])
      if (dispatcher != "")
        print combo " — " dispatcher params
    }
  }'
}

LIST=""
for f in "${CONF_FILES[@]}"; do
  [[ -f "$f" ]] || continue
  LIST+=$(parse_binds < "$f")
  LIST+=$'\n'
done

[[ -z "$LIST" ]] && exit 1

printf '%s\n' "$LIST" \
  | sort -u \
  | rofi -dmenu \
      -i \
      -matching fuzzy \
      -sorting-method fzf \
      -no-sort \
      -no-fixed-num-lines \
      -lines 20 \
      -width 60 \
      -p "🔍 Keybinds" \
      -mesg "$MSG" \
      -config "$ROFI_THEME"
