-- Hyprland 0.57 - Girdi (Input) ve Klavye/Fare

hl.config({
    input = {
        kb_layout  = "tr",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity = -0.7, -- 0 = varsayılan (no modification)

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})
