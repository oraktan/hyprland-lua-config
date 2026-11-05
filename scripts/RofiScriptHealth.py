#!/usr/bin/env python3

import ast
import os
import re
import shutil
import subprocess
import tempfile
from pathlib import Path

HOME = Path.home()
SCRIPTS = HOME / ".config/hypr/scripts"

# Yaygin Hyprland/Rofi bagimliliklari
COMMANDS = [
    "rofi", "hyprctl", "jq", "ghostty",
    "kitty", "nvim", "nano", "swww",
    "waybar", "grim", "slurp", "swappy",
    "wl-copy", "wl-paste", "cliphist",
    "playerctl", "pactl", "wpctl",
    "brightnessctl", "nmcli", "bluetoothctl",
    "notify-send", "wlogout", "swaylock",
    "hyprlock", "hypridle", "hyprpaper",
    "swaybg", "wallust", "matugen",
    "curl", "wget", "fzf", "yad",
    "zenity", "ffmpeg", "mpv"
]

def get_scripts():
    result = []

    if not SCRIPTS.is_dir():
        return result

    # Stow symlink kok dizinini takip eder
    root = SCRIPTS.resolve()

    for folder, dirs, files in os.walk(root):
        dirs[:] = [
            d for d in dirs
            if d not in {".git", "__pycache__", ".venv"}
        ]

        for name in files:
            path = Path(folder) / name

            if path.suffix not in {".sh", ".py"}:
                continue

            if name.endswith((".bak.sh", ".old.sh")):
                continue

            result.append(path)

    return sorted(result, key=lambda p: str(p).lower())

def syntax_check(path):
    if path.suffix == ".py":
        try:
            source = path.read_text(
                encoding="utf-8", errors="replace"
            )
            ast.parse(source, filename=str(path))
            return None
        except SyntaxError as e:
            return f"Python satir {e.lineno}: {e.msg}"
        except OSError as e:
            return str(e)

    # Shebang'a gore kabuk sec
    try:
        first = path.open(
            encoding="utf-8", errors="replace"
        ).readline()
    except OSError as e:
        return str(e)

    if first.startswith("#!") and "zsh" in first:
        shell = "zsh"
    elif first.startswith("#!") and "bash" in first:
        shell = "bash"
    else:
        shell = "sh"

    if not shutil.which(shell):
        return f"Shell bulunamadi: {shell}"

    try:
        check = subprocess.run(
            [shell, "-n", str(path)],
            capture_output=True,
            text=True,
            timeout=10
        )

        if check.returncode != 0:
            return (
                check.stderr.strip()
                or check.stdout.strip()
                or "Sozdizimi hatasi"
            )

    except subprocess.TimeoutExpired:
        return "Sozdizimi kontrolu zaman asimina ugradi"
    except OSError as e:
        return str(e)

    return None

def dependency_check(path):
    try:
        content = path.read_text(
            encoding="utf-8", errors="replace"
        )
    except OSError:
        return []

    # Yalnizca muhtemel komut cagirilari.
    # Kesin bagimlilik analizi degildir.
    lines = [
        line.strip()
        for line in content.splitlines()
        if line.strip()
        and not line.lstrip().startswith("#")
    ]

    missing = set()

    for cmd in COMMANDS:
        pattern = (
            r"(?:^|[|;&(]\s*|\$\(\s*)"
            + re.escape(cmd)
            + r"(?=\s|$)"
        )

        if any(re.search(pattern, line) for line in lines):
            if not shutil.which(cmd):
                missing.add(cmd)

    return sorted(missing)

def inspect(path):
    errors = []
    warnings = []
    details = []

    if path.is_symlink():
        if not path.exists():
            errors.append("Bozuk symlink")
        else:
            details.append(
                f"Symlink hedefi: {path.resolve()}"
            )

    if not path.is_file():
        errors.append("Dosya okunamiyor")
        return errors, warnings, details

    if not os.access(path, os.X_OK):
        warnings.append(
            "Calistirma izni yok. "
            "Gerekirse chmod +x kullan."
        )

    syntax_error = syntax_check(path)

    if syntax_error:
        errors.append(syntax_error)

    missing = dependency_check(path)

    if missing:
        warnings.append(
            "Olasi eksik bagimlilik: "
            + ", ".join(missing)
        )

    if not errors:
        details.append("Sozdizimi: OK")

    return errors, warnings, details

def build_report(items):
    output = [
        "HYPRLAND SCRIPT HEALTH REPORT",
        "=" * 55,
        f"Script klasoru: {SCRIPTS}",
        f"Toplam taranan: {len(items)}",
        ""
    ]

    errors_count = 0
    warnings_count = 0
    ok_count = 0
    statuses = []

    for path in items:
        errors, warnings, details = inspect(path)

        if errors:
            status = "ERROR"
            errors_count += 1
        elif warnings:
            status = "WARNING"
            warnings_count += 1
        else:
            status = "OK"
            ok_count += 1

        statuses.append((path, status))

        output.extend([
            "-" * 55,
            f"[{status}] {path.name}",
            f"Yol: {path}",
        ])

        for error in errors:
            output.append(f"  HATA: {error}")

        for warning in warnings:
            output.append(f"  UYARI: {warning}")

        for detail in details:
            output.append(f"  BILGI: {detail}")

        output.append("")

    output[4:4] = [
        f"OK: {ok_count}",
        f"WARNING: {warnings_count}",
        f"ERROR: {errors_count}",
        ""
    ]

    return "\n".join(output), statuses

def show_report(report):
    fd, filename = tempfile.mkstemp(
        prefix="hypr-health-",
        suffix=".txt"
    )

    with os.fdopen(fd, "w", encoding="utf-8") as f:
        f.write(report)

    if shutil.which("ghostty"):
        subprocess.Popen([
            "ghostty",
            "--title=Script Health Report",
            "-e", "less", "-R", filename
        ], start_new_session=True)

    else:
        print(report)
        print(f"\nRapor dosyasi: {filename}")

def main():
    if not shutil.which("rofi"):
        print("HATA: rofi bulunamadi")
        return

    scripts = get_scripts()

    if not scripts:
        print(f"Script bulunamadi: {SCRIPTS}")
        return

    report, statuses = build_report(scripts)

    menu = ["Tum Raporu Gor"]
    menu.append("Sadece Sorunlu Scriptler")

    for path, status in statuses:
        symbol = {
            "OK": "[OK]",
            "WARNING": "[!]",
            "ERROR": "[X]"
        }[status]

        menu.append(f"{symbol} {path.name}")

    proc = subprocess.run(
        [
            "rofi",
            "-dmenu",
            "-i",
            "-no-custom",
            "-format", "i",
            "-p", "Script Health",
            "-mesg", "Script sec veya tum raporu gor",
            "-l", "15"
        ],
        input="\n".join(menu),
        text=True,
        capture_output=True
    )

    if proc.returncode != 0:
        return

    try:
        choice = int(proc.stdout.strip())
    except ValueError:
        return

    if choice == 0:
        show_report(report)

    elif choice == 1:
        bad = [
            path for path, status in statuses
            if status != "OK"
        ]

        if not bad:
            show_report(
                "Kontrol edilen scriptlerde "
                "tespit edilen sorun yok."
            )
        else:
            filtered_report, _ = build_report(bad)
            show_report(filtered_report)

    else:
        index = choice - 2

        if 0 <= index < len(scripts):
            single_report, _ = build_report(
                [scripts[index]]
            )
            show_report(single_report)

if __name__ == "__main__":
    main()
