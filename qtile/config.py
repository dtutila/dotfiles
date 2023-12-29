# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

from libqtile import bar, layout, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
#from libqtile.utils import guess_terminal
import colors
import os
import subprocess

from libqtile import hook
#from qtile_extras import widget
from qtile_extras.widget.decorations import BorderDecoration


@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~/.config/qtile/autostart.sh')
    subprocess.Popen([home])

mod = "mod4"
#terminal = guess_terminal()
"""
Color schemes live here
"""
_jagl = {
	'bg':   		'#1e1e2e',
	'fg':			'#cdd6f4',
    'dark-red':     '#eba0ac',
    'red':          '#f38ba8',
    'dark-green':   '#94e2d5',
    'green':        '#a6e3a1',
    'dark-yellow':  '#fab387',
    'yellow':       '#f9e2af',
    'dark-blue':    '#74c7ec',
    'blue':         '#89b4fa',
    'dark-magenta': '#cba6f7',
    'magenta':      '#f5c2e7',
    'dark-cyan':    '#94e2d5',
    'cyan':         '#89dceb',
    'dark-gray':    '#7f849c',
    'gray':         '#9399b2',

    'fg4':          '#7f849c',
    'fg3':          '#6c7086',
    'fg2':          '#585b70',
    'fg1':          '#45475a',
    'bg0':          '#313244',
    'fg0':          '#181825',
    'fg9':          '#bac2de'
}

_gruvbox = {
    'bg':           '#282828',
    'fg':           '#d4be98',
    'dark-red':     '#ea6962',
    'red':          '#ea6962',
    'dark-green':   '#a9b665',
    'green':        '#a9b665',
    'dark-yellow':  '#e78a4e',
    'yellow':       '#d8a657',
    'dark-blue':    '#7daea3',
    'blue':         '#7daea3',
    'dark-magenta': '#d3869b',
    'magenta':      '#d3869b',
    'dark-cyan':    '#89b482',
    'cyan':         '#89b482',
    'dark-gray':    '#665c54',
    'gray':         '#928374',

    'fg4':          '#766f64',
    'fg3':          '#665c54',
    'fg2':          '#504945',
    'fg1':          '#3c3836',
    'bg0':          '#32302f',
    'fg0':          '#1d2021',
    'fg9':          '#ebdbb2'
}

color_schema = _gruvbox

### COLORSCHEME ###
# Colors are defined in a separate 'colors.py' file.
# There 10 colorschemes available to choose from:
#
# colors = colors.DoomOne
# colors = colors.Dracula
# colors = colors.GruvboxDark
# colors = colors.MonokaiPro
# colors = colors.Nord
# colors = colors.OceanicNext
# colors = colors.Palenight
# colors = colors.SolarizedDark
# colors = colors.SolarizedLight
# colors = colors.TomorrowNight
#
# It is best not manually change the colorscheme; instead run 'dtos-colorscheme'
# which is set to 'MOD + p c'

colors = colors.DoomOne


keys = [

# Add dedicated sxhkdrc to autostart.sh script

# CLOSE WINDOW, RELOAD AND QUIT QTILE
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "shift"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "shift"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    #Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),

# CHANGE FOCUS USING VIM OR DIRECTIONAL KEYS
    Key([mod], "Up", lazy.layout.up()),
    Key([mod], "Down", lazy.layout.down()),
    Key([mod], "Left", lazy.layout.left()),
    Key([mod], "Right", lazy.layout.right()),
    Key([mod], "k", lazy.layout.up()),
    Key([mod], "j", lazy.layout.down()),
    Key([mod], "h", lazy.layout.left()),
    Key([mod], "l", lazy.layout.right()),

# MOVE WINDOWS UP OR DOWN,LEFT OR RIGHT USING VIM KEYS
    Key([mod, "shift"], "k", lazy.layout.shuffle_up()),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down()),
    Key([mod, "shift"], "h", lazy.layout.swap_column_left()),
    Key([mod, "shift"], "l", lazy.layout.swap_column_right()),

# MOVE WINDOWS UP OR DOWN,LEFT OR RIGHT USING DIRECTIONAL KEYS
    Key([mod, "shift"], "Up", lazy.layout.shuffle_up()),
    Key([mod, "shift"], "Down", lazy.layout.shuffle_down()),
    Key([mod, "shift"], "Left", lazy.layout.swap_column_left()),
    Key([mod, "shift"], "Right", lazy.layout.swap_column_right()),

# RESIZE UP, DOWN, LEFT, RIGHT USING VIM KEYS
    Key([mod, "control"], "l",
        lazy.layout.grow_right(),
        lazy.layout.grow(),
        lazy.layout.increase_ratio(),
        lazy.layout.delete(),
        ),
    Key([mod, "control"], "h",
        lazy.layout.grow_left(),
        lazy.layout.shrink(),
        lazy.layout.decrease_ratio(),
        lazy.layout.add(),
        ),
    Key([mod, "control"], "k",
        lazy.layout.grow_up(),
        lazy.layout.grow(),
        lazy.layout.decrease_nmaster(),
        ),
    Key([mod, "control"], "j",
        lazy.layout.grow_down(),
        lazy.layout.shrink(),
        lazy.layout.increase_nmaster(),
        ),

# RESIZE UP, DOWN, LEFT, RIGHT USING DIRECTIONAL KEYS
    Key([mod, "control"], "Right",
        lazy.layout.grow_right(),
        lazy.layout.grow(),
        lazy.layout.increase_ratio(),
        lazy.layout.delete(),
        ),
     Key([mod, "control"], "Left",
        lazy.layout.grow_left(),
        lazy.layout.shrink(),
        lazy.layout.decrease_ratio(),
        lazy.layout.add(),
        ),
     Key([mod, "control"], "Up",
        lazy.layout.grow_up(),
        lazy.layout.grow(),
        lazy.layout.decrease_nmaster(),
        ),
     Key([mod, "control"], "Down",
        lazy.layout.grow_down(),
        lazy.layout.shrink(),
        lazy.layout.increase_nmaster(),
        ),

    Key([], "XF86AudioLowerVolume", 
        lazy.spawn("amixer sset Master 2%-"), 
        desc="Lower Volume by 2%"
        ),
    Key([], "XF86AudioRaiseVolume", 
        lazy.spawn("amixer sset Master 2%+"), 
        desc="Raise Volume by 2%"),
    Key([], "XF86AudioMute", 
        lazy.spawn("amixer sset Master 1+ toggle"), 
        desc="Mute/Unmute Volume"),
    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause"), desc="Play/Pause player"),

    Key([], "XF86AudioNext", lazy.spawn("playerctl next"), desc="Skip to next"),

    Key([], "XF86AudioPrev", lazy.spawn("playerctl previous"), desc="Skip to previous"),      
    Key([], "XF86Calculator", lazy.spawn("gnome-calculator"), desc="Calculator"),      
       # Switch focus of monitors
    Key([mod], "period", lazy.next_screen(), desc='Move focus to next monitor'),
    Key([mod], "comma", lazy.prev_screen(), desc='Move focus to prev monitor'),



# QTILE LAYOUT KEYS
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),

# TOGGLE FLOATING LAYOUT
    Key([mod, "shift"], "space", lazy.window.toggle_floating()),
	Key([mod, "shift"], "z", lazy.layout.normalize(), desc="Reset all window sizes"),

    ]
# end of keys

#groups = [Group(i) for i in ["", "", "", "", "阮", "", "", "", ""]]
groups = [Group(i) for i in ["1", "2", "3", "4", "5", "6", "7", "8", "9"]]
group_hotkeys = "123456789"

for i in groups:
    keys.extend(
        [
            # mod1 + letter of group = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # mod1 + shift + letter of group = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(i.name),
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod1 + shift + letter of group = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

### LAYOUTS ###
# Some settings that I use on almost every layout, which saves us
# from having to type these out for each individual layout.
layout_theme = {"border_width": 2,
                "margin": 0,
                "border_focus": '#0390fc',# colors[8],
                "border_normal": colors[0]
                }


layouts = [
    layout.MonadTall(**layout_theme),
    layout.Columns(num_columns=2, insert_position=1, **layout_theme),
    layout.Max( border_width = 0, margin = 0,),
    layout.Stack(**layout_theme, num_stacks=2),
    layout.Columns(**layout_theme),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    layout.VerticalTile(),
    # layout.Zoomy(),
]

widget_defaults = dict(
	font='Hack Nerd Font Regular',
    # background=color_schema['bg'],
    # foreground=color_schema['fg'],
    background=colors[0],
    foreground=colors[1],
    fontsize=12,
    padding=2,
)
extension_defaults = widget_defaults.copy()
separator = widget.Sep(size_percent=50, foreground=color_schema['fg3'], linewidth =1, padding =10)
spacer = widget.Sep(size_percent=50, foreground=color_schema['fg3'], linewidth =0, padding =10)

window_name = widget.WindowName()
screen1 = Screen(
            top=bar.Bar(
                [
                    widget.GroupBox(
                        disable_drag=True,
                        use_mouse_wheel=False,
                        # active=color_schema['fg'],
                        active=colors[8],
                        inactive=color_schema['fg3'],
                        highlight_method='line',
                        this_current_screen_border=color_schema['dark-yellow'],
                        hide_unused = False,
                        rounded = False,
                        urgent_alert_method='line',
                        urgent_text=color_schema['dark-red']
                    ),
                    widget.WindowName(),
                        widget.CheckUpdates(
                        distro='Debian',
                        colour_have_updates=color_schema['yellow'],
                        colour_no_updates=color_schema['dark-yellow'],
                        display_format='  Updates: {updates}',
                        no_update_string= '  Updates: 0'
                ),
                separator,
                widget.CPU(
                        format=" {load_percent:04}%",
                        foreground=color_schema['dark-magenta'],
                ),
                separator,
                widget.Memory(
                    format='󰻠{MemUsed: .0f}{mm}/{MemTotal: .0f}{mm}',
                    measure_mem='G',
                    foreground=color_schema['magenta']
                ),
                separator,
                    widget.Clock(format=' %a, %b %-d',
                        foreground=color_schema['fg3']
                    ),
                    widget.Clock(format='%-I:%M %p',
                        foreground=color_schema['fg9']
                    ),
                    separator,
                widget.Volume(
                        fmt="󰕾 {}",
                        mute_command="amixer -D pulse set Master toggle",
                        foreground=color_schema['red']
                ),
                    separator,
                    widget.CurrentLayoutIcon(
                        custom_icon_paths=["/home/drew/.config/qtile/icons/layouts"],
                        scale=0.5,
                        padding=0
                    ),
                    separator,
                    widget.Systray(
                        padding = 6,
                    ),
                    spacer,
                ],
                24,
                # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
                # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
            ),
        )

screen2 = Screen(
            top=bar.Bar(
                [
                    widget.GroupBox(
                        disable_drag=True,
                        use_mouse_wheel=False,
                        # active=color_schema['fg'],
                        active=colors[8],
                        inactive=color_schema['fg3'],
                        highlight_method='line',
                        this_current_screen_border=color_schema['dark-yellow'],
                        hide_unused = False,
                        rounded = False,
                        urgent_alert_method='line',
                        urgent_text=color_schema['dark-red']
                    ),
                    widget.WindowName(),
                        widget.CheckUpdates(
                        distro='Debian',
                        colour_have_updates=color_schema['yellow'],
                        colour_no_updates=color_schema['dark-yellow'],
                        display_format='  Updates: {updates}',
                        no_update_string= '  Updates: 0'
                ),
                separator,
                widget.CPU(
                        format=" {load_percent:04}%",
                        foreground=color_schema['dark-magenta'],
                ),
                separator,
                widget.Memory(
                    format='󰻠{MemUsed: .0f}{mm}/{MemTotal: .0f}{mm}',
                    measure_mem='G',
                    foreground=color_schema['magenta']
                ),
                separator,
                    widget.Clock(format=' %a, %b %-d',
                        foreground=color_schema['fg3']
                    ),
                    widget.Clock(format='%-I:%M %p',
                        foreground=color_schema['fg9']
                    ),
                    separator,
                widget.Volume(
                        fmt="󰕾 {}",
                        mute_command="amixer -D pulse set Master toggle",
                        foreground=color_schema['red']
                ),
                    separator,
                    widget.CurrentLayoutIcon(
                        custom_icon_paths=["/home/drew/.config/qtile/icons/layouts"],
                        scale=0.5,
                        padding=0
                    ),
                    separator,
                    # widget.Systray(
                    #     padding = 6,
                    # ),
                    spacer,
                ],
                24,
                # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
                # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
            ),
        )

screens = [
    screen2,
    screen1

]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="qimgv"),  # q image viewer
        Match(wm_class="Galculator"),  # calculator
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
