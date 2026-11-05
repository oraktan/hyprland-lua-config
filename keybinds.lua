
-- Hyprland 0.57 - kullanici kisayollari
-- Yukleme: hyprland.lua dosyasinin SONUNDA require("keybinds")
-- Eski .conf syntax'i burada kullanilmaz.

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

-- Varsayilan Lua kisayollarindan farkli bir gorev verdiklerimizi kaldir.
-- Diger varsayilanlar (workspace, ses, parlaklik, mouse) korunur.
for _, key in ipairs({
    "SUPER + Q", "SUPER + C", "SUPER + M", "SUPER + E",
    "SUPER + V", "SUPER + R", "SUPER + P", "SUPER + S", "SUPER + SHIFT + S"
}) do hl.unbind(key) end

-- TEMEL UYGULAMALAR / ARAMA
run("SUPER + RETURN", "ghostty", "Terminal")
run("CTRL + ALT + T", "ghostty", "Terminal alternatif")
run("SUPER + E", "dolphin ~", "Dosya yoneticisi Dolphin")
run("SUPER + D", "ghostty --working-directory=\"$HOME/Downloads\" -e yazi", "Yazi Downloads")
run("SUPER + B", rofi .. "bluetooth-menu.sh", "Bluetooth")
-- Eski Wi-Fi komutu /home/thinkpad altina isaret ediyordu. Dogrulanmadan etkinlestirmiyoruz.
-- run("SUPER + I", home .. "/dotfiles/scripts/scripts/rofi-wifi-menu/rofi-wifi-menu.sh", "Wi-Fi")
run("SUPER + SPACE", "pkill rofi || rofi -show drun -modi drun,filebrowser,run,window", "Uygulama menusu")
run("SUPER + F", scripts .. "rofi-search.sh", "Arama")
run("SUPER + y", scripts .. "filesearch.sh", "Dosya arama")
run("SUPER + W", scripts .. "window-switcher.sh", "Pencere sec")
script("SUPER + A", "OverviewToggle.sh", nil, "Masaustu gorunumu")

-- PENCERE / OTURUM
bind("SUPER + Q", hl.dsp.window.close(), "Pencereyi kapat")
script("SUPER + SHIFT + Q", "KillActiveProcess.sh", nil, "Aktif islemi sonlandir")
run("SUPER + L", "hyprlock", "Ekrani kilitle")
script("CTRL + ALT + L", "LockScreen.sh", nil, "Ekrani kilitle")
script("CTRL + ALT + P", "Wlogout.sh", nil, "Guc menusu")
-- ALT+F4 eskiden bilgisayari uyutuyordu; kazayla uyutmayi onlemek icin etkin degil.
-- run("ALT + F4", "systemctl suspend", "Uyku")
run("SUPER + SHIFT + N", "swaync-client -t -sw", "Bildirimler")
script("SUPER + SHIFT + E", "Kool_Quick_Settings.sh", nil, "Hizli ayarlar")
bind("SUPER + G", hl.dsp.group.toggle(), "Pencere grubu")
bind("SUPER + CTRL + K", hl.dsp.window.move({into_group = "l"}), "Gruba sola")
bind("SUPER + CTRL + L", hl.dsp.window.move({into_group = "r"}), "Gruba saga")
bind("SUPER + CTRL + H", hl.dsp.window.move({out_of_group = true}), "Gruptan cikar")
bind("SUPER + CTRL + RETURN", hl.dsp.layout("swapwithmaster"), "Master ile degistir")
bind("SUPER + CTRL + D", hl.dsp.layout("removemaster"), "Master kaldir")
-- SUPER+I Wi-Fi icin ayrildi; eski addmaster ile cakismasin.
bind("SUPER + SHIFT + I", hl.dsp.layout("togglesplit"), "Bolunmeyi degistir")
bind("SUPER + P", hl.dsp.window.pseudo(), "Pseudo")
bind("SUPER + S", hl.dsp.window.fullscreen({mode = "maximized"}), "Pencereyi buyut")
-- Opacity toggle: eski komut yeni Lua API ile dogrulanmadigi icin pasif.

-- ODAGI DEGISTIR / PENCERE TASI / SWAP / BOYUT
bind("CTRL + j", hl.dsp.focus({direction = "d"}), "Asagi odak")
bind("CTRL + k", hl.dsp.focus({direction = "u"}), "Yukari odak")
for _, item in ipairs({{"left","l"},{"right","r"},{"up","u"},{"down","d"}}) do
    local key, direction = item[1], item[2]
    bind("SUPER + CTRL + " .. key, hl.dsp.window.move({direction = direction}), "Pencere tasi " .. key)
    bind("SUPER + ALT + " .. key, hl.dsp.window.swap({direction = direction}), "Pencere swap " .. key)
end
for _, item in ipairs({{"left",-50,0},{"right",50,0},{"up",0,-50},{"down",0,50}}) do
    bind("SUPER + SHIFT + " .. item[1],
        hl.dsp.window.resize({x = item[2], y = item[3], relative = true}),
        "Pencere boyutlandir " .. item[1], {repeating = true})
end
bind("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.alter_zorder({mode = "top"}))
end, "Pencere degistir")

-- WORKSPACE: Eski varsayilan SUPER + rakam ve SHIFT + rakam ana dosyada var.
for i = 1, 10 do
    local key = tostring(i % 10)
    bind("SUPER + CTRL + " .. key,
        hl.dsp.window.move({workspace = i, follow = false}), "Sessiz tasi " .. i)
    bind("SUPER + F" .. i,
        hl.dsp.window.move({workspace = i}), "F tusu ile tasi " .. i)
end
bind("CTRL + ALT + right", hl.dsp.focus({workspace = "e+1"}), "Sonraki workspace")
bind("CTRL + ALT + left", hl.dsp.focus({workspace = "e-1"}), "Onceki workspace")
bind("SUPER + comma", hl.dsp.focus({workspace = "e-1"}), "Onceki workspace")
bind("F1", hl.dsp.focus({workspace = "previous"}), "Onceki calisma alani")
bind("SUPER + U", hl.dsp.workspace.toggle_special("special"), "Scratchpad")
bind("SUPER + SHIFT + U", hl.dsp.window.move({workspace = "special:special"}), "Scratchpad'e tasi")
for _, item in ipairs({{"F9","l"},{"F10","r"},{"F11","u"},{"F12","d"}}) do
    bind("SUPER + CTRL + " .. item[1],
        hl.dsp.workspace.move({monitor = item[2]}), "Workspace monitor degistir")
end

-- TARAYICI PROFILLERI
run("CTRL + ALT + 5", "thunderbird", "Thunderbird")

-- EKRAN GORUNTUSU / KAYIT
script("Print", "ScreenShot2.sh", "--swappy", "Swappy ekran goruntusu")
script("SUPER + Print", "ScreenShot.sh", "--area", "Bolge ekrani")
script("SUPER + CTRL + Print", "ScreenShot.sh", "--in5", "5 sn ekran goruntusu")
script("SUPER + CTRL + SHIFT + Print", "ScreenShot.sh", "--in10", "10 sn ekran goruntusu")
script("ALT + Print", "ScreenShot.sh", "--active", "Aktif pencere goruntusu")
script("SUPER + SHIFT + S", "ScreenShot.sh", "--swappy", "Swappy")
run("SUPER + R", scripts .. "record.sh", "Ekran kaydi")

-- TEMALAR / WAYBAR
for _, item in ipairs({
 {"SUPER + ALT + R","Refresh.sh","Waybar yenile"},
 {"SUPER + SHIFT + A","Animations.sh","Animasyon"},
 {"SUPER + ALT + O","ChangeBlur.sh","Blur"},
 {"SUPER + SHIFT + G","GameMode.sh","Oyun modu"},
 {"SUPER + ALT + L","ChangeLayout.sh","Layout"},
 {"SUPER + CTRL + B","WaybarStyles.sh","Waybar stili"},
 {"SUPER + ALT + B","WaybarLayout.sh","Waybar yerlesimi"},
 {"SUPER + CTRL + R","RofiThemeSelector.sh","Rofi temasi"},
 {"SUPER + CTRL + SHIFT + R","RofiThemeSelector-modified.sh","Rofi tema alternatif"},
 {"SUPER + N","Hyprsunset.sh","Gece isigi", "toggle"},
 {"SUPER + SHIFT + W","WallpaperEffects.sh","Duvar kagidi efekti"},
 {"CTRL + ALT + W","WallpaperRandom.sh","Rastgele duvar kagidi"},
 {"SUPER + ALT + W","WallpaperSelect.sh","Duvar kagidi sec"},
 {"SUPER + SHIFT + O","ZshChangeTheme.sh","Zsh temasi"}
}) do script(item[1], item[2], item[4], item[3]) end
run("SUPER + CTRL + ALT + B", "pkill -SIGUSR1 waybar", "Waybar ac/kapat")

-- PANO / NOTLAR / ARACLAR
script("SUPER + V", "RofiCopyHist.sh", nil, "Pano gecmisi")
script("SUPER + C", "RofiCalc.sh", nil, "Hesap makinesi")
script("SUPER + period", "RofiEmoji.sh", nil, "Emoji")
script("SUPER + SHIFT + M", "RofiBeats.sh", nil, "Muzik")
script("SUPER + M", "RofiBeats.sh", nil, "Muzik")
run("SUPER + O", home .. "/dotfiles/scripts/scripts/ocr.sh", "OCR")
script("SUPER + H", "KeyBinds.sh", nil, "Kisayollar")
script("SUPER + SHIFT + RETURN", "Dropterminal.sh", "ghostty", "Acilir terminal")
run("code:78", "kitty -e btop", "Sistem monitoru")
-- code:127 WhatsApp odagi icin yeni API ile ayrica uyarlanacak.
run("SUPER + ALT + V", scripts .. "dict.sh", "Sozluk")
run("MOD5 + F1", "dolphin \"$HOME/Downloads\"", "Indirilenler")
run("MOD5 + F2", "dolphin \"$HOME/Documents\"", "Belgeler")
-- /home/thinkpad/Documents/Personel Evraklari yolu bu kullanicida dogrulanmadi.
-- run("MOD5 + F3", "dolphin ...", "Personel evraklari")
---- Bölge seç → panoya kopyala
-- run("Print", 'grim -g "$(slurp)" - | wl-copy', "Bölge → pano")
-- Bölge seç → swappy ile düzenle
-- run("SUPER + Print", 'grim -g "$(slurp)" - | swappy -f -', "Bölge → swappy")
-- Tüm ekran → dosya + pano
run("SUPER + CTRL + Print",
    'f="$HOME/Pictures/Screenshots/$(date +%F_%H-%M-%S).png"; mkdir -p "$(dirname "$f")"; grim "$f" && wl-copy < "$f"',
    "Tam ekran")
-- NUMPAD ile workspace (NumLock açık/kapalı fark etmez)
-- keycode: KP_1=87, KP_2=88, KP_3=89, KP_4=83, KP_5=84, KP_6=85, KP_7=79, KP_8=80, KP_9=81, KP_0=90
local numpad = {87, 88, 89, 83, 84, 85, 79, 80, 81, 90}
for i, code in ipairs(numpad) do
    bind("SUPER + code:" .. code,
        hl.dsp.focus({workspace = i}), "Numpad workspace " .. i)
    bind("SUPER + SHIFT + code:" .. code,
        hl.dsp.window.move({workspace = i}), "Numpad pencereyi tasi " .. i)
end
-- NUMPAD workspace: {NumLock açık, NumLock kapalı}
local numpad = {
    {"KP_1","KP_End"},   {"KP_2","KP_Down"}, {"KP_3","KP_Next"},
    {"KP_4","KP_Left"},  {"KP_5","KP_Begin"},{"KP_6","KP_Right"},
    {"KP_7","KP_Home"},  {"KP_8","KP_Up"},   {"KP_9","KP_Prior"},
    {"KP_0","KP_Insert"},
}
for i, keys in ipairs(numpad) do
    for _, k in ipairs(keys) do
        bind(k, hl.dsp.focus({workspace = i}), "Numpad ws " .. i)
        bind("SHIFT + " .. k, hl.dsp.window.move({workspace = i}), "Numpad tasi " .. i)
    end
end


-- Firefox Profiles -- 

hl.bind("CTRL + ALT + 1", function()
    hl.dispatch(hl.dsp.focus({ workspace = 1 }))
    hl.dispatch(hl.dsp.exec_cmd("firefox -P taner --new-instance"))
end)

hl.bind("CTRL + ALT + 2", function()
    hl.dispatch(hl.dsp.focus({ workspace = 2 }))
    hl.dispatch(hl.dsp.exec_cmd("firefox -P work --new-instance"))
end)

hl.bind("CTRL + ALT + 3", function()
    hl.dispatch(hl.dsp.focus({ workspace = 3 }))
    hl.dispatch(hl.dsp.exec_cmd("firefox -P whatsapp --new-instance"))
end)

hl.bind("CTRL + ALT + 4", function()
    hl.dispatch(hl.dsp.focus({ workspace = 4 }))
    hl.dispatch(hl.dsp.exec_cmd("firefox -P info --new-instance"))
end)
