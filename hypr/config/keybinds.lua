local mainMod = "SUPER"
local noctCall = "noctalia msg "
local launchPrefix = "uwsm app -- " -- if you are not using UWSM, make this empty (e.g. "")

---------------------------
---- WINDOW MANAGEMENT ----
---------------------------

hl.bind(mainMod .. " + Escape",      hl.dsp.exec_cmd("hyprctl kill"))
hl.bind(mainMod .. " + Q",           hl.dsp.window.close())
hl.bind(mainMod .. " + ALT + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D",           hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mainMod .. " + F",           hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + J",           hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + L",           hl.dsp.exec_cmd(noctCall .. "session lock"))
hl.bind(mainMod .. " + ALT + C",     hl.dsp.exec_cmd(noctCall .. "panel-toggle session"))

-- Change focus
hl.bind(mainMod .. " + Left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + Up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + Down",  hl.dsp.focus({ direction = "down" }))
hl.bind("ALT + Tab",           hl.dsp.window.cycle_next())

-- Move active window around current workspace
hl.bind(mainMod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + Left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + Up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + Down",  hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + CONTROL + SHIFT + Right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mainMod .. " + CONTROL + SHIFT + Left",  hl.dsp.window.move({ workspace = "r-1" }))

-- Move & Resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

------------------
---- LAUNCHER ----
------------------

hl.bind(mainMod .. " + Return",     hl.dsp.exec_cmd(launchPrefix .. TERMINAL))
hl.bind(mainMod .. " + E",          hl.dsp.exec_cmd(launchPrefix .. FILE_MANAGER))
hl.bind(mainMod .. " + T",          hl.dsp.exec_cmd(launchPrefix .. EDITOR))
hl.bind(mainMod .. " + C",          hl.dsp.exec_cmd(launchPrefix .. CALCULATOR))
hl.bind("XF86Calculator",           hl.dsp.exec_cmd("gnome-calculator"))
hl.bind(mainMod .. " + B",          hl.dsp.exec_cmd(launchPrefix .. BROWSER))
hl.bind(mainMod .. " + G",          hl.dsp.exec_cmd(launchPrefix .. CHROME))
hl.bind("CONTROL + SHIFT + Escape", hl.dsp.exec_cmd(launchPrefix .. TERMINAL .. " -e btop"))
hl.bind(mainMod .. " + Z",          hl.dsp.exec_cmd(noctCall .. "settings-toggle"))
hl.bind(mainMod .. " + X",          hl.dsp.exec_cmd(noctCall .. "panel-toggle control-center"))
hl.bind(mainMod .. " + Space",      hl.dsp.exec_cmd(noctCall .. "panel-toggle launcher"))
hl.bind(mainMod .. " + period",     hl.dsp.exec_cmd(noctCall .. "panel-toggle launcher /emoji"))

-- Web apps
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd(launchPrefix .. WEB_APP .. '="https://web.whatsapp.com/"'))
hl.bind(mainMod .. " + I",         hl.dsp.exec_cmd(launchPrefix .. WEB_APP .. '="https://claude.ai/"'))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.exec_cmd(launchPrefix .. WEB_APP .. '="https://chatgpt.com/"'))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(launchPrefix .. WEB_APP .. '="https://x.com/"'))

---------------------------
---- HARDWARE CONTROLS ----
---------------------------

-- Audio
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(noctCall .. "volume-up"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(noctCall .. "volume-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(noctCall .. "volume-mute"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(noctCall .. "mic-mute"),    { locked = true, repeating = true })

-- Media
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd(noctCall .. "media toggle"),   { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(noctCall .. "media pause"),    { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd(noctCall .. "media next"),     { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd(noctCall .. "media previous"), { locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(noctCall .. "brightness-up"),   { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(noctCall .. "brightness-down"), { repeating = true })

-------------------
---- UTILITIES ----
-------------------

-- Screen Capture
-- Noctalia 5 dropped the QML plugin API, so the old screen-toolkit plugin is gone.
-- Screenshots are now built in; the color picker needs the community color_picker plugin.
-- hl.bind(mainMod .. " + P",  hl.dsp.exec_cmd(noctCall .. "plugin oldirtty/color_picker:main bar pick"))
hl.bind("Print",               hl.dsp.exec_cmd("$HOME/.local/bin/screenshot.sh"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd(noctCall .. "screenshot-fullscreen"))
hl.bind(mainMod .. " + R",     hl.dsp.exec_cmd(noctCall .. "screenshot-region"))

-- Theming and Wallpaper
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(noctCall .. "panel-toggle wallpaper"))

-- Clipboard
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(noctCall .. "panel-toggle clipboard"))

-- Dictation
-- voxtray installs to ~/.local/bin, which is not on the compositor's PATH, so call it
-- by absolute path -- a bare "voxtray" resolves to nothing and the bind silently no-ops.
hl.bind(mainMod .. " + CONTROL + Space", hl.dsp.exec_cmd("$HOME/.local/bin/voxtray toggle"))

-- OpenWhispr
-- XDG_CURRENT_DESKTOP=Hyprland:GNOME (uwsm/env-hyprland) makes OpenWhispr pick its
-- GNOME backend, which registers hotkeys in gsettings -- Hyprland never sees them.
-- Its D-Bus service still runs, so bind the keys here and call it directly.
-- Keep the key combos in sync with OpenWhispr's settings. Dictation must use "Tap"
-- activation mode: the GNOME D-Bus API has no key-up event, so "Hold" ignores Toggle.
local whispr = "dbus-send --session --type=method_call --dest=com.openwhispr.App /com/openwhispr/App com.openwhispr.App."
hl.bind("F8",                      hl.dsp.exec_cmd(whispr .. "Toggle"))
hl.bind("CONTROL + SHIFT + Space", hl.dsp.exec_cmd(whispr .. "ToggleVoiceAgent"))
hl.bind("CONTROL + SHIFT + K",     hl.dsp.exec_cmd(whispr .. "ToggleMeeting"))

--------------------
---- WORKSPACES ----
--------------------

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = true }))
end

-- Switch to / move window to workspaces 11-20 with mainMod + ALT + [0-9]
for i = 1, 10 do
    local key = i % 10
    local workspace = i + 10
    hl.bind(mainMod .. " + ALT + " .. key,         hl.dsp.focus({ workspace = workspace }))
    hl.bind(mainMod .. " + ALT + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace, follow = true }))
end

-- Workspaces 21-22
hl.bind(mainMod .. " + minus",         hl.dsp.focus({ workspace = 21 }))
hl.bind(mainMod .. " + equal",         hl.dsp.focus({ workspace = 22 }))
hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.move({ workspace = 21, follow = true }))
hl.bind(mainMod .. " + SHIFT + equal", hl.dsp.window.move({ workspace = 22, follow = true }))

hl.bind(mainMod .. " + CONTROL + Right",       hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mainMod .. " + CONTROL + Left",        hl.dsp.focus({ workspace = "r-1" }))
hl.bind(mainMod .. " + CONTROL + Down",        hl.dsp.focus({ workspace = "empty" }))
hl.bind(mainMod .. " + CONTROL + ALT + Right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mainMod .. " + CONTROL + ALT + Left",  hl.dsp.window.move({ workspace = "r-1" }))

-- Scroll through existing workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special" }))
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special())

-----------------------
---- NOTIFICATIONS ----
-----------------------

hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(noctCall .. "panel-toggle control-center notifications"))
