-- Genel monitor varsayilani
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- Lenovo: Yatay, solda
hl.monitor({
    output = "DP-2",
    mode = "1920x1080@60",
    position = "0x0",
    scale = 1,
    transform = 0,
})

-- Samsung: Dikey, sağda
hl.monitor({
    output = "HDMI-A-1",
    mode = "1920x1080@60",
    position = "1920x0",
    scale = 1,
    transform = 1,
})

-- WORKSPACE -> MONITOR EŞLEŞTİRMELERİ
local left  = "DP-2"       -- sol (0x0)
local right = "HDMI-A-1"   -- sağ (1920x0, dikey)

-- Workspace 1-5 sol monitöre (Lenovo)
for i = 1, 5 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor = left,
        default = (i == 1),
        persistent = true
    })
end

-- Workspace 6-10 sağ monitöre (Samsung)
for i = 6, 10 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor = right,
        default = (i == 6),
        persistent = true
    })
end
