-- Hyprland 0.57 - Autostart (Başlangıç Uygulamaları)

hl.config({
    exec_once = {
        "waybar",
        "nm-applet --indicator",
        "blueman-applet"
    }
})
