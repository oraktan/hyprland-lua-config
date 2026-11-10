-- Hyprland 0.57
-- Fedora 44 | Modular Lua Configuration

-- Environment
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRLAND_NO_RT", "1")
-- Display and input
require("lua.monitors")
require("lua.input")

-- Appearance and system
require("lua.appearance")
require("lua.animations")
require("lua.core")

-- Window rules and shortcuts
require("lua.windowrules")
require("lua.keybinds")

-- Startup applications
require("lua.autostart")
