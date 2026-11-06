-- Hyprland 0.57 - Kisisel pencere kurallari
-- Lenovo: workspace 1-5 | Samsung: workspace 6-10

-- Firefox profilleri: sinifa gore workspace
for _, item in ipairs({
    {"firefox-taner",    "1"},
    {"firefox-work",     "2"},
    {"firefox-whatsapp", "3"},
    {"firefox-info",     "4"},
}) do
    hl.window_rule({
        match = { class = "^(" .. item[1] .. ")$" },
        workspace = item[2],
    })
end

-- Thunderbird: workspace 5
hl.window_rule({
    match = { class = "^(net.thunderbird.Thunderbird)$" },
    workspace = "5",
})

-- Ghostty: workspace 6
hl.window_rule({
    match = { class = "^(com.mitchellh.ghostty)$" },
    workspace = "6",
})

-- LibreOffice: workspace 7
hl.window_rule({
    match = { class = "^(libreoffice.*)$" },
    workspace = "7",
})

-- Okular: workspace 8
hl.window_rule({
    match = { class = "^(org.kde.okular)$" },
    workspace = "8",
})

-- Telegram: workspace 9
hl.window_rule({
    match = { class = "^(org.telegram.desktop|telegram-desktop)$" },
    workspace = "9",
})

-- GNOME Loupe: ortada, floating, %60 boyutlu, opak
hl.window_rule({
    match = { class = "^(org.gnome.Loupe)$" },
    float = true,
    size = { "60%", "60%" },
    center = true,
    opacity = "1.0 override 1.0 override",
})

-- Mousepad: ortada, floating, sabit boyutlu, tum workspace'lerde
hl.window_rule({
    match = { class = "^(mousepad)$" },
    float = true,
    size = { "800", "500" },
    center = true,
    opacity = "0.95 override 0.85 override",
    pin = true,
})

-- Ana yapilandirmadan tasinan kurallar
hl.window_rule({
    match = { class = ".*" },
    suppressevent = "maximize",
})

hl.window_rule({
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})
