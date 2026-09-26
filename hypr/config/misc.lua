hl.config({
    dwindle = {
        preserve_split = true,
    },
    misc = {
        col = {
            splash = CACHYLGREEN,
        },
        middle_click_paste = false,
        enable_swallow = true,
        swallow_regex = "(kitty|ghostty|[Kk]onsole|Alacritty|gnome-terminal|xfce[0-9]?-terminal)",
        vrr = 3,
        -- Let a restarted Noctalia take the lock back if the lock client dies.
        allow_session_lock_restore = true,
        disable_splash_rendering = true,
    },
    cursor = {
        hide_on_key_press = true,
        warp_on_change_workspace = 1,
    },
    binds = {
        hide_special_on_workspace_change = true,
    },
    xwayland = {
        force_zero_scaling = true
    },
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },
})