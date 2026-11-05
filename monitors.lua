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
-- WORKSPACE -> MONITOR
local left  = "DP-2"       -- sol (0x0)
local right = "HDMI-A-1"   -- sağ (1920x0)

for i = 1, 5 do
    hl.workspace_rule({ workspace = tostring(i), monitor = left,
                        default = (i == 1), persistent = true })
end
for i = 6, 9 do
    hl.workspace_rule({ workspace = tostring(i), monitor = right,
                        default = (i == 6), persistent = true })
end
