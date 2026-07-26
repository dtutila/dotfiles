# dotfiles

Personal configuration for a [Hyprland](https://hypr.land/) desktop on
[CachyOS](https://cachyos.org/) (Arch-based), with the
[Noctalia](https://github.com/noctalia-dev/noctalia-shell) 5 bar,
kitty, and tmux.

## Components

| Path | What it configures |
| --- | --- |
| `hypr/` | Hyprland, configured with the Lua DSL (`hl.*`). Split into `config/*.lua` modules loaded by `hyprland.lua`. |
| `noctalia/` | Noctalia 5 shell (bar, panels, theming) — `config.toml`. See [Noctalia config layering](#noctalia-config-layering). |
| `kitty/` | kitty terminal config and themes. |
| `.tmux.conf` | tmux configuration. |
| `bin/screenshot.sh` | Region screenshot via `hyprshot` + `satty` (annotate, copy to clipboard, save to `~/Pictures/Screenshots`). |

### Hyprland modules (`hypr/config/`)

`animations`, `autostart`, `colors`, `decorations`, `defaults`, `environment`,
`input`, `keybinds`, `misc`, `monitors`, `windowrules`, `workspaces`.

- **Monitors** — `DP-1` 2560x1440@165 (primary), `HDMI-A-1` 2560x1440@144 rotated 90° (`transform = 1`).
- **Workspaces** — `1–10` pinned to `DP-1`, `11–22` pinned to `HDMI-A-1`. All are
  `persistent` so Hyprland pre-creates them at startup in numeric order (this keeps
  the Noctalia workspace pills ordered, since Noctalia renders them in creation order).
- **Default apps** — kitty (terminal), nautilus (files), firefox (browser),
  Sublime Text (editor), chromium (web apps).
- **Autostart** — launches the Noctalia shell (`noctalia --daemon`) and the polkit agent.

### Noctalia config layering

Noctalia 5 resolves its settings in two layers:

1. every `*.toml` in the config dir (`~/.config/noctalia` → this repo), then
2. `~/.local/state/noctalia/settings.toml`, which **overrides** them.

The Settings UI only ever writes to that state file, so anything changed in the UI
shadows `noctalia/config.toml` until it is folded back into the repo:

```sh
noctalia config export merged     # what layer 1 + layer 2 resolve to
noctalia config export full       # the same, with every default filled in
noctalia config validate          # syntax, unknown keys, bad values
```

Move the new keys into `noctalia/config.toml`, then delete them from the state file
(keep `config_version`, and leave the generated `lockscreen_widgets` and `wallpaper`
blocks alone — those are runtime state, not intent). `config.toml` deliberately holds
only what differs from the shipped defaults. Noctalia reads *every* `*.toml` in the
directory, so it can be split into modules later if it grows.

## Requirements

Hyprland (with Lua config support, as shipped by CachyOS), `noctalia` 5,
`kitty`, `tmux`, and for screenshots `hyprshot`, `satty`, and
`wl-clipboard`.

## Install

Configs are symlinked from this repo into `~/.config` (and `~` for tmux):

```sh
git clone git@gitlab.com:dtutila/dotfiles.git ~/src/personal/dotfiles
cd ~/src/personal/dotfiles

ln -s "$PWD/hypr"     ~/.config/hypr
ln -s "$PWD/kitty"    ~/.config/kitty
ln -s "$PWD/noctalia" ~/.config/noctalia
ln -s "$PWD/.tmux.conf" ~/.tmux.conf
```

Then reload Hyprland (`hyprctl reload`) or log out and back in.
