#!/bin/bash

# Aktif interface al
IFACE=$(nmcli -t -f DEVICE,TYPE,STATE dev | grep wifi | grep connected | cut -d: -f1)

# Wi-Fi bağlı mı?
if [ -n "$IFACE" ]; then
    WIFI="ON"
else
    WIFI="OFF"
fi

# Internet var mı?
if ping -c 1 -W 1 1.1.1.1 > /dev/null 2>&1; then
    NET="ON"
else
    NET="OFF"
fi

# VPN aktif mi?
if nmcli -t -f NAME,TYPE con show --active | grep -q ':vpn'; then
    VPN="ON"
else
    VPN="OFF"
fi

# ICON logic
if [ "$WIFI" = "OFF" ]; then
    ICON="󰖪"   # wifi off
elif [ "$NET" = "OFF" ]; then
    ICON="󰖩"   # connected no internet
elif [ "$VPN" = "ON" ]; then
    ICON="󰕥"   # secure
else
    ICON="󰖨"   # normal wifi
fi

# SSID al
SSID=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d: -f2)

echo "$ICON $SSID"
