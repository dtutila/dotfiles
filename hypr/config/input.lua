-- Input configuration

hl.config({
    input = {
        accel_profile = "adaptive",
        repeat_rate = 40,
        repeat_delay = 250,
        numlock_by_default = true,
    },
})

hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "down",       action = "close" })
hl.gesture({ fingers = 3, direction = "up",         action = "fullscreen" })
hl.gesture({ fingers = 3, direction = "left",       action = "float" })

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})