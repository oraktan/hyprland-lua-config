-- Hyprland 0.57 - Temizlenmiş Klavye Kısayolları

local mainMod = "SUPER"
local terminal = "ghostty"
local fileManager = "dolphin"
local menu = "pkill rofi || rofi -show drun -modi drun,filebrowser,run,window"

local home = os.getenv("HOME") or "/home/fedora"
local scripts = home .. "/.config/hypr/scripts/"
local rofi = home .. "/.config/rofi/"

local function bind(key, dispatcher, description, flags)
    flags = flags or {}
    if description then flags.description = description end
    hl.bind(key, dispatcher, flags)
end
local function run(key, command, description, flags)
    bind(key, hl.dsp.exec_cmd(command), description, flags)
end
local function script(key, filename, args, description)
    run(key, scripts .. filename .. (args and (" " .. args) or ""), description)
end

-- 1. TEMEL UYGULAMALAR & ARAMA
run(mainMod .. " + RETURN", terminal, "Terminal")
run("CTRL + ALT + T", terminal, "Terminal (Alternatif)")
run(mainMod .. " + E", fileManager .. " ~", "Dosya Yöneticisi")
run(mainMod .. " + SPACE", menu, "Uygulama Menüsü")
run(mainMod .. " + D", terminal .. " --working-directory=\"$HOME/Downloads\" -e yazi", "Yazi (Downloads)")
run(mainMod .. " + B", rofi .. "bluetooth-menu.sh", "Bluetooth Menüsü")
run(mainMod .. " + F", scripts .. "rofi-search.sh", "Arama")
run(mainMod .. " + Y", scripts .. "filesearch.sh", "Dosya Arama")
run(mainMod .. " + W", scripts .. "window-switcher.sh", "Pencere Seçici")
script(mainMod .. " + A", "OverviewToggle.sh", nil, "Masaüstü Görünümü")

-- 2. PENCERE & DÜZEN YÖNETİMİ
bind(mainMod .. " + Q", hl.dsp.window.close(), "Pencereyi Kapat")
script(mainMod .. " + SHIFT + Q", "KillActiveProcess.sh", nil, "Aktif İşlemi Sonlandır")
bind(mainMod .. " + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }), "Kayan (Float) Pencere Geçişi")
bind(mainMod .. " + P", hl.dsp.window.pseudo(), "Pseudo Döşeme")
bind(mainMod .. " + J", hl.dsp.layout("togglesplit"), "Bölünmeyi Değiştir")
bind(mainMod .. " + S", hl.dsp.window.fullscreen({mode = "maximized"}), "Pencereyi Büyüt (Maximize)")

bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }), "Sola Odak")
bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }), "Sağa Odak")
bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }), "Yukarı Odak")
bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }), "Aşağı Odak")
bind("CTRL + j", hl.dsp.focus({direction = "d"}), "Aşağı Odak (Vim)")
bind("CTRL + k", hl.dsp.focus({direction = "u"}), "Yukarı Odak (Vim)")

for _, item in ipairs({{"left","l"},{"right","r"},{"up","u"},{"down","d"}}) do
    local key, dir = item[1], item[2]
    bind(mainMod .. " + CTRL + " .. key, hl.dsp.window.move({direction = dir}), "Pencere Taşı " .. key)
    bind(mainMod .. " + ALT + " .. key, hl.dsp.window.swap({direction = dir}), "Pencere Takas " .. key)
end

for _, item in ipairs({{"left",-50,0},{"right",50,0},{"up",0,-50},{"down",0,50}}) do
    bind(mainMod .. " + SHIFT + " .. item[1],
        hl.dsp.window.resize({x = item[2], y = item[3], relative = true}),
        "Boyutlandır " .. item[1], {repeating = true})
end

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

bind(mainMod .. " + G", hl.dsp.group.toggle(), "Pencere Grubu")
bind(mainMod .. " + CTRL + K", hl.dsp.window.move({into_group = "l"}), "Gruba Sola Ekle")
bind(mainMod .. " + CTRL + L", hl.dsp.window.move({into_group = "r"}), "Gruba Sağa Ekle")
bind(mainMod .. " + CTRL + H", hl.dsp.window.move({out_of_group = true}), "Gruptan Çıkar")

bind("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.alter_zorder({mode = "top"}))
end, "Pencere Değiştir (Alt+Tab)")

-- 3. WORKSPACE (ÇALIŞMA ALANI) YÖNETİMİ

-- SUPER + 1-9 / SUPER + 0: Masaüstüne geç
-- SUPER + F1-F10: Pencereyi masaüstüne taşı
for i = 1, 10 do
    local key = tostring(i % 10)

    bind(mainMod .. " + " .. key,
        hl.dsp.focus({workspace = i}),
        "Workspace " .. i)

    bind(mainMod .. " + SHIFT + " .. key,
        hl.dsp.window.move({workspace = i}),
        "Pencereyi Taşı WS " .. i)

    bind(mainMod .. " + CTRL + " .. key,
        hl.dsp.window.move({workspace = i, follow = false}),
        "Sessiz Taşı WS " .. i)

    bind(mainMod .. " + F" .. i,
        hl.dsp.window.move({workspace = i}),
        "F Tuşu İle Taşı WS " .. i)
end

bind(mainMod .. " + mouse_down",
    hl.dsp.focus({workspace = "e+1"}), "Sonraki Workspace (Fare)")
bind(mainMod .. " + mouse_up",
    hl.dsp.focus({workspace = "e-1"}), "Önceki Workspace (Fare)")
bind("CTRL + ALT + right",
    hl.dsp.focus({workspace = "e+1"}), "Sonraki Workspace")
bind("CTRL + ALT + left",
    hl.dsp.focus({workspace = "e-1"}), "Önceki Workspace")
bind(mainMod .. " + comma",
    hl.dsp.focus({workspace = "e-1"}), "Önceki Workspace (,)")
bind("F1",
    hl.dsp.focus({workspace = "previous"}), "Önceki Çalışma Alanı")

-- NUMPAD: SUPER olmadan masaüstüne geç
-- Num Lock açık ve kapalı tuş adları
local numpad = {
    {"KP_1", "KP_End"},
    {"KP_2", "KP_Down"},
    {"KP_3", "KP_Next"},
    {"KP_4", "KP_Left"},
    {"KP_5", "KP_Begin"},
    {"KP_6", "KP_Right"},
    {"KP_7", "KP_Home"},
    {"KP_8", "KP_Up"},
    {"KP_9", "KP_Prior"},
    {"KP_0", "KP_Insert"}
}

for i, keys in ipairs(numpad) do
    for _, key in ipairs(keys) do
        bind(key,
            hl.dsp.focus({workspace = i}),
            "Numpad Workspace " .. i)
    end
end

bind(mainMod .. " + U", hl.dsp.workspace.toggle_special("special"), "Scratchpad")
bind(mainMod .. " + SHIFT + U", hl.dsp.window.move({workspace = "special:special"}), "Scratchpad'e Taşı")

for _, item in ipairs({{"F9","l"},{"F10","r"},{"F11","u"},{"F12","d"}}) do
    bind(mainMod .. " + CTRL + " .. item[1],
        hl.dsp.workspace.move({monitor = item[2]}), "Workspace Monitor Değiştir " .. item[2])
end

-- 4. UYGULAMA PROFİLLERİ (Tarayıcı & E-Posta)
run("CTRL + ALT + 5", "thunderbird -p taner", "Thunderbird (taner)")
local ff_profiles = { {1, "taner"}, {2, "work"}, {3, "whatsapp"}, {4, "info"} }
for _, p in ipairs(ff_profiles) do
    hl.bind("CTRL + ALT + " .. tostring(p[1]), function()
        hl.dispatch(hl.dsp.focus({ workspace = p[1] }))
        hl.dispatch(hl.dsp.exec_cmd("firefox -P " .. p[2] .. " --new-instance"))
    end, {description = "Firefox " .. p[2]})
end

-- 5. MEDYA & DONANIM KONTROLLERİ
bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), "Ses Artır", { locked = true, repeating = true })
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), "Ses Azalt", { locked = true, repeating = true })
bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), "Sesi Kapat", { locked = true })
bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), "Mikrofonu Kapat", { locked = true })
bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), "Parlaklık Artır", { locked = true, repeating = true })
bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), "Parlaklık Azalt", { locked = true, repeating = true })
bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"), "Sonraki Şarkı", { locked = true })
bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), "Oynat/Duraklat", { locked = true })
bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), "Oynat/Duraklat", { locked = true })
bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"), "Önceki Şarkı", { locked = true })

-- 6. SİSTEM, ROFI SCRIPTLERI & EKRAN GÖRÜNTÜSÜ
run(mainMod .. " + L", "hyprlock", "Ekranı Kilitle")
script("CTRL + ALT + P", "Wlogout.sh", nil, "Güç Menüsü")
run(mainMod .. " + SHIFT + N", "swaync-client -t -sw", "Bildirim Merkezi")
script(mainMod .. " + SHIFT + E", "Kool_Quick_Settings.sh", nil, "Hızlı Ayarlar")

script(mainMod .. " + V", "hist.sh", nil, "Pano Geçmişi")
script(mainMod .. " + C", "RofiCalc.sh", nil, "Hesap Makinesi")
script(mainMod .. " + period", "RofiEmoji.sh", nil, "Emoji Menüsü")
script(mainMod .. " + SHIFT + M", "RofiBeats.sh", nil, "Müzik Menüsü")
run(mainMod .. " + O", home .. "/dotfiles/scripts/scripts/ocr.sh", "OCR Okuma")
script(mainMod .. " + H", "KeyBinds.sh", nil, "Kısayollar Menüsü")
script(mainMod .. " + SHIFT + RETURN", "Dropterminal.sh", "ghostty", "Açılır Terminal")
run("code:78", "kitty -e btop", "Sistem Monitörü")
run(mainMod .. " + ALT + V", scripts .. "dict.sh", "Sözlük")

run("MOD5 + F1", fileManager .. " \"$HOME/Downloads\"", "İndirilenler")
run("MOD5 + F2", fileManager .. " \"$HOME/Documents\"", "Belgeler")

run("CTRL + ALT + 6", "thunderbird -P taner", "Thunderbird Taner Profili")

script("Print", "ScreenShot2.sh", "--swappy", "Swappy Ekran Görüntüsü")
script(mainMod .. " + Print", "ScreenShot.sh", "--area", "Bölge Ekran Görüntüsü")
script(mainMod .. " + CTRL + Print", "ScreenShot.sh", "--in5", "5 Saniye Gecikmeli Görüntü")
script(mainMod .. " + CTRL + SHIFT + Print", "ScreenShot.sh", "--in10", "10 Saniye Gecikmeli Görüntü")
script("ALT + Print", "ScreenShot.sh", "--active", "Aktif Pencere Görüntüsü")
script(mainMod .. " + SHIFT + S", "ScreenShot.sh", "--swappy", "Swappy Düzenleyici")
run(mainMod .. " + R", scripts .. "record.sh", "Ekran Kaydı")
run("Insert", "kwrite ~/notlar.txt", "Whatsapp Paylaş")

local ui_scripts = {
    {"SUPER + ALT + R","Refresh.sh","Waybar Yenile"},
    {"SUPER + SHIFT + A","Animations.sh","Animasyon Profilleri"},
    {"SUPER + ALT + O","ChangeBlur.sh","Blur Geçişi"},
    {"SUPER + SHIFT + G","GameMode.sh","Oyun Modu"},
    {"SUPER + ALT + L","ChangeLayout.sh","Layout Geçişi"},
    {"SUPER + CTRL + B","WaybarStyles.sh","Waybar Stili"},
    {"SUPER + ALT + B","WaybarLayout.sh","Waybar Yerleşimi"},
    {"SUPER + CTRL + R","RofiThemeSelector.sh","Rofi Teması"},
    {"SUPER + CTRL + SHIFT + R","RofiThemeSelector-modified.sh","Rofi Tema (Alternatif)"},
    {"SUPER + N","Hyprsunset.sh","Gece Işığı", "toggle"},
    {"SUPER + SHIFT + W","WallpaperEffects.sh","Duvar Kağıdı Efekti"},
    {"CTRL + ALT + W","WallpaperRandom.sh","Rastgele Duvar Kağıdı"},
    {"SUPER + ALT + W","WallpaperSelect.sh","Duvar Kağıdı Seç"},
    {"SUPER + SHIFT + O","ZshChangeTheme.sh","Zsh Teması"}
}
for _, item in ipairs(ui_scripts) do script(item[1], item[2], item[4], item[3]) end
-- 6. SİSTEM, ROFI SCRIPTLERI & EKRAN GÖRÜNTÜSÜ
---- SUPER + L: Ekranı kilitle
hl.bind("SUPER + L",
    hl.dsp.exec_cmd("pidof hyprlock || hyprlock"),
    { description = "Ekranı Kilitle" }
)

-- ALT + F4: Uyku moduna al
run(
    "ALT + F4",
    "systemctl suspend",
    "Uyku Moduna Al"
)

-- ALT + F4: Önce ekranı kilitle, sonra uykuya geç
