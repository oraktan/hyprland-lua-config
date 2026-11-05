#!/usr/bin/env python3

import json
import os
import shutil
import subprocess
import time
import urllib.parse
import xml.etree.ElementTree as ET
from pathlib import Path

HOME = Path.home()
CONFIG = Path(
    os.environ.get("XDG_CONFIG_HOME", HOME / ".config")
).expanduser()

DATA = Path(
    os.environ.get("XDG_DATA_HOME", HOME / ".local/share")
).expanduser()

DB = DATA / "smart-config-editor" / "history.json"

EXTENSIONS = {
    ".conf", ".json", ".jsonc", ".rasi",
    ".css", ".lua", ".toml", ".ini",
    ".yaml", ".yml", ".xml", ".desktop",
    ".properties"
}

# Gereksiz klasorleri tarama
IGNORE = {
    ".git", "node_modules", "__pycache__",
    "cache", "Cache", ".cache",
    "venv", ".venv", "scripts",
    "Scripts", "extensions"
}

def load_history():
    try:
        return json.loads(DB.read_text())
    except (OSError, ValueError):
        return {}

def save_history(data):
    DB.parent.mkdir(parents=True, exist_ok=True)
    DB.write_text(
        json.dumps(data, indent=2, ensure_ascii=False)
    )

def scan_configs():
    found = set()

    if CONFIG.is_dir():
        for root, dirs, files in os.walk(CONFIG, followlinks=True):
            dirs[:] = [
                d for d in dirs
                if d not in IGNORE and not d.startswith(".")
            ]

            for filename in files:
                path = Path(root) / filename
                if path.suffix.lower() in EXTENSIONS:
                    found.add(str(path))

    # Ek config dosyalari
    extras = [
        HOME / ".zshrc",
        HOME / ".bashrc",
        HOME / ".profile",
        HOME / ".gitconfig",
        HOME / ".vimrc",
        HOME / ".tmux.conf",
        HOME / ".Xresources"
    ]

    for path in extras:
        if path.is_file():
            found.add(str(path))

    return found

def gtk_recent():
    result = {}

    recent = DATA / "recently-used.xbel"

    if not recent.is_file():
        return result

    try:
        tree = ET.parse(recent)
        root = tree.getroot()

        for item in root.iter():
            if not item.tag.endswith("bookmark"):
                continue

            uri = item.get("href", "")

            parsed = urllib.parse.urlparse(uri)

            if parsed.scheme != "file":
                continue

            path = urllib.parse.unquote(parsed.path)

            if not path:
                continue

            count = 0

            for child in item.iter():
                if child.tag.endswith("application"):
                    try:
                        count += int(child.get("count", 0))
                    except ValueError:
                        pass

            result[path] = max(count, 1)

    except (ET.ParseError, OSError):
        pass

    return result



def open_editor(path):
    # Varsayilan editor Neovim
    editor = os.environ.get("CONFIG_EDITOR", "nvim")

    # Ghostty kurulu mu?
    if not shutil.which("ghostty"):
        subprocess.run([
            "notify-send",
            "-u", "critical",
            "Config Editor",
            "Ghostty bulunamadi!"
        ])
        return False

    # Editor mevcut mu?
    if not shutil.which(editor):
        subprocess.run([
            "notify-send",
            "-u", "critical",
            "Config Editor",
            f"Editor bulunamadi: {editor}"
        ])
        return False

    # Dosyayi Ghostty terminalinde ac
    try:
        subprocess.Popen([
            "ghostty",
            "--title=Config Editor",
            "-e",
            editor,
            path
        ], start_new_session=True)

        return True

    except OSError as error:
        subprocess.run([
            "notify-send",
            "-u", "critical",
            "Config Editor",
            str(error)
        ])
        return False
def main():
    history = load_history()
    files = scan_configs()
    recent = gtk_recent()

    # Onceki kayitlardan silinmemis dosyalar
    for path in history:
        if Path(path).is_file():
            files.add(path)

    def rank(path):
        own = history.get(path, {})
        count = own.get("count", 0)
        last = own.get("last", 0)
        gtk_count = recent.get(path, 0)

        # Kendi kullanim istatistikleri oncelikli
        return (
            count * 1000 + gtk_count * 100,
            last
        )

    ordered = sorted(
        files,
        key=lambda p: (
            -rank(p)[0],
            -rank(p)[1],
            p.lower()
        )
    )

    if not ordered:
        subprocess.run([
            "notify-send", "Config Editor",
            "Config dosyasi bulunamadi"
        ])
        return

    labels = []

    for path in ordered:
        own_count = history.get(path, {}).get("count", 0)
        gtk_count = recent.get(path, 0)

        try:
            relative = Path(path).relative_to(HOME)
            name = "~/" + str(relative)
        except ValueError:
            name = path

        if own_count:
            prefix = f"★ {own_count}x"
        elif gtk_count:
            prefix = f"◷ {gtk_count}x"
        else:
            prefix = "  "

        labels.append(f"{prefix}  {name}")

    proc = subprocess.run(
        [
            "rofi",
            "-dmenu",
            "-i",
            "-no-custom",
            "-format", "i",
            "-p", "Config Editor",
            "-mesg", "★ En cok actiklarin | ◷ GTK gecmisi",
            "-l", "15"
        ],
        input="\n".join(labels),
        text=True,
        capture_output=True
    )

    if proc.returncode != 0:
        return

    try:
        index = int(proc.stdout.strip())
        selected = ordered[index]
    except (ValueError, IndexError):
        return

    if open_editor(selected):
        record = history.get(selected, {})
        record["count"] = record.get("count", 0) + 1
        record["last"] = time.time()
        history[selected] = record
        save_history(history)
    else:
        subprocess.run([
            "notify-send", "-u", "critical",
            "Config Editor",
            "Uygun editor veya terminal bulunamadi"
        ])

if __name__ == "__main__":
    main()
