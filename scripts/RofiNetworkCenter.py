
#!/usr/bin/env python3

import os
import re
import shutil
import subprocess

# ==========================================
# HYPRLAND NETWORK & BLUETOOTH CENTER
# Rofi + Ghostty + NetworkManager + BlueZ
# ==========================================

MAC_PATTERN = re.compile(
    r"^[0-9A-Fa-f]{2}(:[0-9A-Fa-f]{2}){5}$"
)


def run(*args, timeout=25):
    try:
        return subprocess.run(
            list(args),
            text=True,
            capture_output=True,
            timeout=timeout
        )
    except (OSError, subprocess.TimeoutExpired) as e:
        return subprocess.CompletedProcess(
            args, 1, "", str(e)
        )


def notify(message, title="Network Center", error=False):
    if shutil.which("notify-send"):
        subprocess.Popen([
            "notify-send",
            "-u", "critical" if error else "normal",
            title, str(message)
        ])
    else:
        print(f"{title}: {message}")


def action(*args, title="Network Center", timeout=30):
    result = run(*args, timeout=timeout)
    if result.returncode == 0:
        notify(result.stdout.strip() or "Islem tamamlandi", title)
        return True

    notify(
        (result.stderr or result.stdout or "Islem basarisiz")
        .strip()[:400],
        title,
        error=True
    )
    return False


def choose(title, options, message=""):
    if not options:
        return None

    result = subprocess.run(
        [
            "rofi", "-dmenu", "-i",
            "-no-custom",
            "-format", "i",
            "-p", title,
            "-mesg", message,
            "-l", "15"
        ],
        input="\n".join(options),
        text=True,
        capture_output=True
    )

    if result.returncode != 0:
        return None

    try:
        index = int(result.stdout.strip())
        if 0 <= index < len(options):
            return index
    except ValueError:
        pass

    return None


def terminal(*args, title="Network Center"):
    if not shutil.which("ghostty"):
        notify("Ghostty bulunamadi", error=True)
        return

    # Komut bittiginde hatalari gorebilmek icin
    # terminal acik tutulur.
    subprocess.Popen([
        "ghostty",
        f"--title={title}",
        "-e", "bash", "-c",
        ' "$@"; status=$?; echo; '
        'echo "Cikis kodu: $status"; '
        'read -r -p "Kapatmak icin Enter..."',
        "bash",
        *args
    ], start_new_session=True)


def split_nmcli(line):
    """nmcli -t cikisindaki kacisli : karakterlerini ayir."""
    values = []
    current = []
    escaped = False

    for char in line:
        if escaped:
            current.append(char)
            escaped = False
        elif char == "\\":
            escaped = True
        elif char == ":":
            values.append("".join(current))
            current = []
        else:
            current.append(char)

    values.append("".join(current))
    return values


# ==========================================
# WIFI
# ==========================================

def wifi_enabled():
    return run("nmcli", "radio", "wifi").stdout.strip() == "enabled"


def wifi_list():
    result = run(
        "nmcli", "-t",
        "-f", "IN-USE,SSID,SIGNAL,SECURITY,BSSID",
        "device", "wifi", "list",
        "--rescan", "no"
    )

    if result.returncode != 0:
        notify(result.stderr.strip(), "Wi-Fi", True)
        return []

    networks = []
    seen = set()

    for line in result.stdout.splitlines():
        parts = split_nmcli(line)

        if len(parts) < 5:
            continue

        active, ssid, signal, security, bssid = parts[:5]

        # Gizli SSID bu menude gosterilmiyor.
        if not ssid or not MAC_PATTERN.fullmatch(bssid):
            continue

        if bssid in seen:
            continue

        seen.add(bssid)

        try:
            strength = int(signal)
        except ValueError:
            strength = 0

        networks.append({
            "ssid": ssid,
            "signal": strength,
            "security": security,
            "bssid": bssid,
            "active": active == "*"
        })

    networks.sort(
        key=lambda x: (not x["active"], -x["signal"])
    )

    return networks


def wifi_networks():
    networks = wifi_list()

    if not networks:
        notify("Ag bulunamadi. Yeniden tara.", "Wi-Fi")
        return

    labels = []

    for network in networks:
        prefix = "●" if network["active"] else "○"
        lock = "🔒" if network["security"] not in ("", "--") else " "
        labels.append(
            f'{prefix} {network["ssid"]}  '
            f'[{network["signal"]}%] {lock}'
        )

    index = choose(
        "Wi-Fi Networks",
        labels,
        "● Bagli | Enter: Ag sec"
    )

    if index is None:
        return

    network = networks[index]

    if network["active"]:
        selection = choose(
            network["ssid"],
            ["Baglantiyi kes", "Geri"]
        )

        if selection == 0:
            # Yalnizca aktif Wi-Fi arayuzunu kes
            device = run(
                "nmcli", "-t", "-f", "DEVICE,TYPE,STATE",
                "device", "status"
            )

            for line in device.stdout.splitlines():
                parts = split_nmcli(line)
                if (
                    len(parts) >= 3
                    and parts[1] == "wifi"
                    and parts[2].startswith("connected")
                ):
                    action(
                        "nmcli", "device", "disconnect", parts[0],
                        title="Wi-Fi"
                    )
                    break
        return

    # Ag sifresi Ghostty icinde interaktif sorulur.
    # Parola process argumanlarina eklenmez.
    terminal(
        "nmcli", "--ask",
        "device", "wifi", "connect",
        network["bssid"],
        title="Wi-Fi Connect"
    )


def wifi_menu():
    while True:
        enabled = wifi_enabled()

        items = [
            "Mevcut Wi-Fi aglari",
            "Aglari yeniden tara",
            "Wi-Fi kapat" if enabled else "Wi-Fi ac",
            "Ag durumu",
            "Geri"
        ]

        selected = choose(
            "Wi-Fi Manager",
            items,
            "NetworkManager"
        )

        if selected is None or selected == 4:
            return

        if selected == 0:
            if enabled:
                wifi_networks()
            else:
                notify("Once Wi-Fi ac", "Wi-Fi")

        elif selected == 1:
            if enabled:
                action(
                    "nmcli", "device", "wifi", "rescan",
                    title="Wi-Fi"
                )
            else:
                notify("Wi-Fi kapali", "Wi-Fi")

        elif selected == 2:
            action(
                "nmcli", "radio", "wifi",
                "off" if enabled else "on",
                title="Wi-Fi"
            )

        elif selected == 3:
            result = run("nmcli", "device", "status")
            notify(result.stdout.strip()[:900], "Wi-Fi Status")


# ==========================================
# BLUETOOTH
# ==========================================

def bluetooth_enabled():
    result = run("bluetoothctl", "show")
    return bool(
        re.search(r"Powered:\s+yes", result.stdout)
    )


def bt_devices():
    result = run("bluetoothctl", "devices")

    devices = []

    for line in result.stdout.splitlines():
        match = re.match(
            r"^Device\s+"
            r"([0-9A-Fa-f:]{17})\s+(.+)$",
            line.strip()
        )

        if match:
            mac, name = match.groups()
            if MAC_PATTERN.fullmatch(mac):
                devices.append((mac, name))

    return devices


def bt_info(mac):
    result = run("bluetoothctl", "info", mac)
    data = result.stdout

    def flag(name):
        return bool(
            re.search(
                rf"^\s*{name}:\s+yes\s*$",
                data,
                re.MULTILINE
            )
        )

    return {
        "paired": flag("Paired"),
        "trusted": flag("Trusted"),
        "connected": flag("Connected")
    }


def bluetooth_scan():
    notify(
        "Tarama baslatildi. Yaklasik 10 saniye.",
        "Bluetooth"
    )

    # BlueZ taramasi gecici olarak yapilir.
    result = run(
        "bluetoothctl", "--timeout", "10",
        "scan", "on",
        timeout=15
    )

    run(
        "bluetoothctl", "scan", "off",
        timeout=5
    )

    if result.returncode != 0:
        notify(
            "Tarama tamamlanamadi. Bluetooth servisini kontrol et.",
            "Bluetooth", True
        )
    else:
        notify(
            "Tarama tamamlandi. Cihaz listesini ac.",
            "Bluetooth"
        )


def bluetooth_device_menu(mac, name):
    while True:
        info = bt_info(mac)

        items = [
            "Baglantiyi kes" if info["connected"] else "Baglan",
            "Eslesme baslat (Ghostty)",
            "Guvenilir olarak isaretle",
            "Cihazi kaldir",
            "Geri"
        ]

        status = (
            f'Eslesmis: {info["paired"]} | '
            f'Bagli: {info["connected"]} | '
            f'Guvenilir: {info["trusted"]}'
        )

        selected = choose(name, items, status)

        if selected is None or selected == 4:
            return

        if selected == 0:
            action(
                "bluetoothctl",
                "disconnect" if info["connected"] else "connect",
                mac,
                title="Bluetooth",
                timeout=45
            )

        elif selected == 1:
            # PIN ve onay isteyebilen eslestirmeler
            # icin gercek terminal kullanilir.
            terminal(
                "bluetoothctl",
                "--agent", "KeyboardDisplay",
                "pair", mac,
                title="Bluetooth Pairing"
            )

        elif selected == 2:
            action(
                "bluetoothctl", "trust", mac,
                title="Bluetooth"
            )

        elif selected == 3:
            confirmation = choose(
                "Cihazi kaldir?",
                [f"Evet, kaldir: {name}", "Vazgec"]
            )

            if confirmation == 0:
                action(
                    "bluetoothctl", "remove", mac,
                    title="Bluetooth"
                )
                return


def bluetooth_devices():
    devices = bt_devices()

    if not devices:
        notify(
            "Cihaz bulunamadi. Tarama yap.",
            "Bluetooth"
        )
        return

    labels = []

    for mac, name in devices:
        info = bt_info(mac)

        if info["connected"]:
            symbol = "●"
        elif info["paired"]:
            symbol = "◉"
        else:
            symbol = "○"

        labels.append(f"{symbol} {name}  [{mac}]")

    selected = choose(
        "Bluetooth Devices",
        labels,
        "● Bagli | ◉ Eslesmis | ○ Yeni"
    )

    if selected is not None:
        mac, name = devices[selected]
        bluetooth_device_menu(mac, name)


def bluetooth_menu():
    while True:
        enabled = bluetooth_enabled()

        items = [
            "Cihazlari listele",
            "Yeni cihazlari tara",
            "Bluetooth kapat" if enabled else "Bluetooth ac",
            "Geri"
        ]

        selected = choose(
            "Bluetooth Manager",
            items,
            "BlueZ / bluetoothctl"
        )

        if selected is None or selected == 3:
            return

        if selected == 0:
            if enabled:
                bluetooth_devices()
            else:
                notify("Bluetooth kapali", "Bluetooth")

        elif selected == 1:
            if enabled:
                bluetooth_scan()
            else:
                notify("Once Bluetooth ac", "Bluetooth")

        elif selected == 2:
            action(
                "bluetoothctl",
                "power", "off" if enabled else "on",
                title="Bluetooth"
            )


# ==========================================
# MAIN MENU
# ==========================================

def main():
    required = ["rofi", "nmcli", "bluetoothctl", "ghostty"]
    missing = [
        name for name in required
        if not shutil.which(name)
    ]

    if missing:
        notify(
            "Eksik komutlar: " + ", ".join(missing),
            error=True
        )
        print("Eksik komutlar:", ", ".join(missing))
        return

    while True:
        wifi = "ACIK" if wifi_enabled() else "KAPALI"
        bt = "ACIK" if bluetooth_enabled() else "KAPALI"

        items = [
            f"Wi-Fi Manager     [{wifi}]",
            f"Bluetooth Manager [{bt}]",
            "Durumu yenile",
            "Cikis"
        ]

        selected = choose(
            "Network Center",
            items,
            "Hyprland Network & Bluetooth Center"
        )

        if selected is None or selected == 3:
            return

        if selected == 0:
            wifi_menu()

        elif selected == 1:
            bluetooth_menu()

        # 2 = Menu yeniden olusturulur


if __name__ == "__main__":
    main()

