-- Remember the size of floating windows per app
hl.window_rule({ match = { float = true }, persistent_size = true })

-- Picture-in-Picture
hl.window_rule({
    match             = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
    float             = true,
    keep_aspect_ratio = true,
    move              = "73% 72%",
    size              = "25% 25%",
    pin               = true,
})

-- Gaming
local gamingApps = "^(steam_app.*|gamescope)$"
local gamingWorkspace = "name:gaming"

hl.window_rule({ match = { content = "game" }, workspace = gamingWorkspace })
hl.window_rule({ match = { xdg_tag = "^(.*game.*)$" }, workspace = gamingWorkspace, fullscreen_state = 2, content = "game", sync_fullscreen = true })
hl.window_rule({ match = { class = gamingApps }, workspace = gamingWorkspace })
hl.window_rule({ match = { class = "^(steam)$", title = "^(Friends List)$" }, float = true })
hl.window_rule({
    match = {
        class = "^(steam)$",
        title = "^(Launching\\.{3})$"
    },
    float     = true,
    center    = true,
    workspace = gamingWorkspace,
})
hl.window_rule({
    match = {
        class         = gamingApps,
        title         = "^(.+)$",
        initial_title = "negative:^(.*\\\\home\\\\.*)$",
    },
    size             = "monitor_w monitor_h",
    fullscreen_state = 2,
    content          = "game",
})
hl.window_rule({
    match = {
        class         = "^(steam_app.*)$",
        initial_title = "^$",
    },
    float            = true,
    center           = true,
    fullscreen       = false,
    fullscreen_state = 0,
})

-- Apps
local primaryWorkspace = 1

hl.window_rule({ match = { class = "^(.*\\.exe)$" }, float = true, workspace = primaryWorkspace, center = true, fullscreen_state = 0 })
hl.window_rule({ match = { class = "^(vesktop|discord)$" }, workspace = primaryWorkspace })
hl.window_rule({ match = { class = "^(.*[Cc]alculator.*)$" }, float = true, size = "380 616" })
hl.window_rule({ match = { class = "^(org.kde.keditfiletype)$" }, float = true })
hl.window_rule({ match = { class = "^(org.kde.ark)$" }, size = "(monitor_w*0.40) (monitor_h*0.40)" })

-- Float file pickers (portal-based browse dialogs)
hl.window_rule({ match = { class = "^(xdg-desktop-portal-hyprland)$" }, float = true })
hl.window_rule({
    match = {
        class = "^(org.kde.dolphin)$",
        title = "negative:^(Moving.*|Create New.*|Extract.*|Compress.*|Copying.*|Progress.*|Configure.*|Properties.*|Choose\\sApplication.*)$",
    },
    float = true,
    move = {
        "max(0, min(cursor_x - 650, monitor_w - 1320))",
        "max(0, min(cursor_y - 50, monitor_h - 820))"
    },
    size = "1300 800",
})

-- Opacity Overrides
local terminals = "^(kitty|ghostty|[Kk]onsole|Alacritty|gnome-terminal|xfce[0-9]?-terminal)$"
local opaqueDesktopApps = "^(Code|code|Postman|Chatgpt|chatgpt|google-chrome|Google-chrome|chromium|Chromium|[Xx]dg-desktop-portal-gtk)$"

hl.window_rule({ match = { class = "^(firefox|org\\.mozilla\\.firefox|zen)$" }, opacity = "1.0 override" })
hl.window_rule({ match = { class = terminals }, opacity = "1.0 override" }) -- override opacity in favor of terminal settings for opacity
hl.window_rule({ match = { class = "^(mpv|org.kde.haruna|.*plex.*|org\\.kde\\.gwenview|.*vlc.*)$" }, opacity = "1.0 override" })
-- Compositor-wide opacity makes Chromium/Electron popup surfaces and GTK file
-- choosers translucent, which exposes blurred content from the parent window.
hl.window_rule({ match = { class = opaqueDesktopApps }, opacity = "1.0 override" })

-- Keep ChatGPT context-menu transparent margins free of compositor blur.
hl.window_rule({
    name = "chatgpt-popup-no-blur",
    match = { class = "^(ChatGPT|Chatgpt|chatgpt)$" },
    no_blur = true,
})

-- Float Utility Windows
local floatApps = {
    { class = "^(com\\.gabm\\.satty)$" },
    { class = "^(swappy)$" },
    { class = "^(kvantummanager|qt[56]ct|nwg-look)$" },
    { class = "^(org.pulseaudio.pavucontrol|blueman-manager|nm-applet|nm-connection-editor)$" },
    { title = "^(Winetricks.*|Protontricks.*)$" },
}
for _, m in ipairs(floatApps) do hl.window_rule({ match = m, float = true }) end

hl.window_rule({ match = { float = true }, move = "50% 50%" })

-- Windscribe — float & center the VPN window.
-- No size rule on purpose: the window collapses/expands to its own height,
-- so we let the app control its dimensions and just float + center it.
-- Placed after the "float -> 50% 50%" catch-all above so `center` wins.
hl.window_rule({ match = { class = "^(Windscribe)$" }, float = true, center = true })

-- Float Common Modals
local modalMatches = {
    { title = "^(Open|Authentication Required|Add Folder to Workspace|Choose Files|Save As|Confirm to replace files|File Operation Progress)$" },
    { initial_title = "^(Open File)$" },
    { class = "^([Xx]dg-desktop-portal-gtk)$" },
    { title = "^(File Upload|Choose wallpaper|Library)(.*)$" },
    { class = "^(.*dialog.*)$" },
    { title = "^(.*dialog.*)$" },
    { class = "^(hyprland-share-picker)$"},
}
for _, m in ipairs(modalMatches) do hl.window_rule({ match = m, float = true }) end

-- Ignore maximize requests from all apps. You'll probably like this.
local suppressMaximizeRule = hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
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


-- Keep password managers out of screen shares
hl.window_rule({ match = { class = "^(1[pP]assword|com\\.onepassword\\.OnePassword)$" }, no_screen_share = true })

-- Hide browser "... is sharing your screen" indicator windows
hl.window_rule({
    match = {
        class = "^(google-chrome|[Cc]hromium|brave-origin|brave-browser)$",
        title = "^.* is sharing (your screen|a window|a tab|this tab)\\.?$",
    },
    workspace = "special silent",
})

-- No border or animation on the slurp region selection used by screenshots
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true, animation = "none" })

-- Blur behind translucent Noctalia surfaces (bar background_opacity = 0.5)
hl.layer_rule({
    name = "noctalia",
    match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
    },
    no_anim = true,
    ignore_alpha = 0.2,
    blur = true,
    blur_popups = true,
})

hl.window_rule({
  match = { class = "voxtray-osd" },
  float = true,
  pin = true,
  center = true,
  no_initial_focus = true,
  no_focus = true,
  border_size = 0,
})
