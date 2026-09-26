# CachyOS, Omarchy and Garuda tweaks for Fedora

## Scope

This is a research note from 2026-09-16. What was applied is recorded in
[6. Applied on 2026-09-16](#6-applied-on-2026-09-16). It lists
defaults and tweaks from CachyOS, Omarchy and Garuda Linux (Hyprland edition)
that could be adopted on this Fedora 44 Hyprland setup, and which ones to skip.

Sources were shallow clones of the upstream repositories plus read-only checks
on this machine. Items marked **unverified** were not confirmed.

- CachyOS: [CachyOS-Settings](https://github.com/CachyOS/CachyOS-Settings),
  [cachyos-zsh-config](https://github.com/CachyOS/cachyos-zsh-config),
  [cachyos-fish-config](https://github.com/CachyOS/cachyos-fish-config),
  [cachyos-hypr-noctalia](https://github.com/CachyOS/cachyos-hypr-noctalia),
  [cachyos-hyprland-settings](https://github.com/CachyOS/cachyos-hyprland-settings),
  [CachyOS wiki](https://wiki.cachyos.org/)
- Omarchy: [basecamp/omarchy](https://github.com/basecamp/omarchy) (commit
  `9c5482c`, 2026-09-16, Hyprland Lua config)
- Garuda: [garuda-linux GitLab](https://gitlab.com/garuda-linux):
  `garuda-hyprland-settings` (`12a53d8`, 2026-08-23, Lua),
  `garuda-common-settings`, `pkgbuilds` (`garuda-zsh-config`,
  `performance-tweaks`, `garuda-update`)

Garuda's Hyprland edition is a **community** edition
(`iso/latest/community/hyprland`). It is still maintained, but its config is
basic (waybar, wofi, mako, nwg-drawer) and has less to borrow than Omarchy.

## Security
No corp or custom kernels are allowed

Items in this note excluded by that rule:

- CachyOS kernel (COPR `bieszczaders/kernel-cachyos`)
- COPR `bieszczaders/kernel-cachyos-addons`: `cachyos-settings`, `scx-scheds`,
  `scx-tools`, `ananicy-cpp`, `cachyos-ananicy-rules`
- `grub-btrfs` from COPR (snapshots must use Fedora-packaged tools only)

zsh plugins are pinned to reviewed commits; see
[zsh plugin pins](zsh-plugin-pins.md).

## System baseline

| Item | Current state |
| --- | --- |
| CPU / GPU / RAM | Ryzen 9 5900X (x86-64-v3, not v4), RX 6400 (amdgpu), 62 GiB |
| Kernel | 7.2.5-200.fc44, `PREEMPT_LAZY`, `HZ=1000`, `CONFIG_SCHED_CLASS_EXT=y` |
| Hyprland | 0.56.2 under UWSM, GDM, Noctalia shell |
| Root filesystem | btrfs, `zstd:1`; Secure Boot disabled |
| tuned profile | **`throughput-performance`** (not Fedora's default `balanced`) |
| Swap | zram0 8G lzo-rle prio 100, **plus a 59.6G swap partition on an HDD** (`sdb1`, prio -1, in `/etc/fstab`) |
| Disks | `sda` SATA SSD (bfq), `sdb` HDD (bfq), NVMe (`none`) |
| sysctl | swappiness 10, dirty ratios 40/10 (from tuned), page-cluster 3, vfs_cache_pressure 100, nmi_watchdog 1, `tcp_congestion_control=cubic` |
| THP | enabled=madvise, defrag=madvise |
| CPU driver | `amd-pstate-epp`, EPP=performance (from tuned) |
| Services | systemd-oomd, firewalld, systemd-resolved active; `thermald` **enabled** (Intel-only, no effect on AMD); `NetworkManager-wait-online` disabled |
| Other | gamemode installed; podman (no docker); 1Password installed; `ntsync` module present but not loaded; `sp5100_tco` watchdog loaded |

### Two facts that change most system advice

1. **tuned owns the VM sysctls.** `throughput-performance` sets swappiness and
   dirty ratios when it starts. It likely overrides `/etc/sysctl.d` (unverified).
   To change them, create a custom tuned profile:

   ```ini
   # /etc/tuned/desktop-custom/tuned.conf
   [main]
   include=throughput-performance

   [sysctl]
   vm.swappiness=150
   ```

   Then run `tuned-adm profile desktop-custom`, or switch to `balanced`.

2. **HDD swap.** A high swappiness with zram becomes harmful once zram fills
   and pages spill onto the spinning disk. Remove or `swapoff` `sdb1` before
   raising swappiness.

## 1. Bugs found in the current dotfiles

| File | Problem | Fix |
| --- | --- | --- |
| `.zshrc` (last line) | `alias cursor= 'cursor --password-store=…'`: a space after `=` defines an empty alias and then errors | `alias cursor='cursor --password-store="gnome-libsecret"'` |
| `.zshrc:98` | `export TERM="xterm-256color"` overrides kitty's `xterm-kitty`, breaking the kitty keyboard protocol, `icat`, and undercurl/truecolor lookups | Remove it |
| `.zshrc:152` | `zoxide init` is not last (p10k/fnm come after), so every shell prints the zoxide "configuration issue" warning | Move it to the end, or set `_ZO_DOCTOR=0` |
| `.zshrc:159` | `_JAVA_AWT_WM_NONREPARENTING=1` only reaches terminal-launched apps | Move it to `uwsm/env-hyprland` |
| `hypr/config/windowrules.lua:52` | `.exe` rule puts `float = true` inside `match` and passes `primaryWorkspace` without a key | `hl.window_rule({ match = { class = "^(.*\\.exe)$" }, float = true, workspace = primaryWorkspace, center = true, fullscreen_state = 0 })` |
| `hypr/config/windowrules.lua:53` | vesktop/discord rule passes `primaryWorkspace` without a key | `workspace = primaryWorkspace` |
| `hypr/config/autostart.lua:9` | `xhost +SI:localuser:root` lets root X11 clients connect | Remove unless needed |
| `hypr/config/autostart.lua:5` | `dbus-update-activation-environment --systemd --all` duplicates what UWSM already does | Harmless; can be removed |
| `electron-flags.conf` | Arch convention. Nothing on Fedora reads it: Chrome's launcher and `/usr/bin/code` do not reference it, and vendor Electron apps likely ignore it (unverified) | Keep flags in launchers, or use `ELECTRON_OZONE_PLATFORM_HINT`; update the README |
| Web-app binds | `WEB_APP`/`CHROME` launches skip `uwsm app --`, so they run under Hyprland's unit instead of `app.slice` | Prefix launches with `uwsm app --` |
| Fonts | `fc-match monospace` returns Noto Sans Mono although JetBrains Mono Nerd Font is installed | See [fontconfig](#fontconfig) |

## 2. Dotfiles-level ideas

### Session environment (`uwsm/env-hyprland`)

| Variable | Source | Note |
| --- | --- | --- |
| `ELECTRON_OZONE_PLATFORM_HINT=auto` (or `wayland`) | CachyOS `uwsm/env`, Omarchy `default/hypr/envs.lua` | Mainly helps older bundled Electron apps; Electron 38+ picks Wayland by itself |
| `HYPRCURSOR_SIZE=24` | CachyOS, Omarchy | Matches existing `XCURSOR_SIZE` |
| `_JAVA_AWT_WM_NONREPARENTING=1` | Garuda `usr/bin/hyprstart` | Move from `.zshrc` |
| `MOZ_DBUS_REMOTE=1` | Garuda `hyprstart` | Optional |
| `TERMINAL=xdg-terminal-exec`, `EDITOR` | Omarchy `default/uwsm/default` | Fedora package `xdg-terminal-exec` |
| `MESA_SHADER_CACHE_MAX_SIZE=12G` | CachyOS wiki `configuration/gaming.mdx` | Only for gaming or heavy GL/Vulkan use |

Do **not** export `BROWSER` session-wide. Omarchy notes that it makes
`xdg-settings` refuse to change the default browser. Also skip
`SDL_VIDEODRIVER=wayland`: Garuda itself warns that it breaks older games.

### Hyprland (`hypr/config/*.lua`)

Omarchy and Garuda both use the Lua config. Omarchy's `o.window` and `o.bind`
are wrappers; use `hl.window_rule` and `hl.bind` instead.

**misc / cursor / binds / input** (Omarchy `default/hypr/looknfeel.lua`,
`default/hypr/input.lua`; CachyOS `config/misc.lua`):

```lua
misc = {
  focus_on_activate = true,
  anr_missed_pings = 3,
  on_focus_under_fullscreen = 1,
  allow_session_lock_restore = true, -- a restarted Noctalia can re-take the lock
  disable_splash_rendering = true,
},
cursor = { hide_on_key_press = true, warp_on_change_workspace = 1 },
binds = { hide_special_on_workspace_change = true },
dwindle = { force_split = 2 },
render = { direct_scanout = 2 }, -- CachyOS; game content only. Try non_shader_cm = 0 on flicker
input = {
  repeat_rate = 40,
  repeat_delay = 250,
  numlock_by_default = true,
  kb_options = "compose:caps,shift:both_capslock_cancel",
},
```

**Window and layer rules:**

```lua
-- Hide password managers from screen sharing (Omarchy default/hypr/apps/1password.lua)
hl.window_rule({ match = { class = "^(1[pP]assword|com\\.onepassword\\.OnePassword)$" },
  no_screen_share = true, float = true, center = true })

-- Send "X is sharing your screen" indicator windows away (Omarchy apps/browser.lua)
hl.window_rule({ match = { title = ".*is sharing.*" }, workspace = "special silent" })

-- No border/animation on slurp region selection (Omarchy apps/screenshot-selection.lua)
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true, animation = "none" })

-- Blur the Noctalia bar (Garuda hyprland.lua blur-all-layers; CachyOS noctalia layer rule)
-- Live namespace from `hyprctl layers`: noctalia-bar-default
hl.layer_rule({ match = { namespace = "^noctalia-bar.*" }, blur = true, ignore_alpha = 0.1 })
```

- **Tag-based opacity** (Omarchy `default/hypr/windows.lua`): give every window
  a `+default-opacity` tag, remove it for media and browsers, and style by tag.
  This replaces the long `opacityOverride` class lists.
- **CachyOS extras** (`config/windowrules.lua`): a `persistent_size` rule for
  floating windows, and an `xdg_tag` game rule with `sync_fullscreen`.

**Binds:**

| Bind | Source | Snippet |
| --- | --- | --- |
| Move workspace to the monitor on the left | Omarchy `bindings/tiling.lua` | `hl.bind("SUPER + SHIFT + ALT + LEFT", hl.dsp.workspace.move({monitor="l"}))` |
| Focus next monitor | same | `hl.bind("CTRL + ALT + TAB", hl.dsp.focus({monitor="+1"}))` |
| Previous workspace | same | `hl.bind("SUPER + CTRL + TAB", hl.dsp.focus({workspace="previous"}))` |
| Tiled fake fullscreen | Omarchy SUPER+CTRL+F, Garuda SUPER+SHIFT+F | `hl.dsp.window.fullscreen_state({internal=0, client=2})` |
| Pop out window (float, resize, center, pin) | Omarchy `bin/omarchy-hyprland-window-pop` | copy the script |
| Toggle window opacity | Omarchy `bin/omarchy-hyprland-window-transparency-toggle` | `hl.dsp.window.set_prop({… prop="opaque", value="toggle"})` |
| Groups (tabbed windows) | Omarchy `bindings/tiling.lua` | `hl.dsp.group.toggle()`, `group.next()/prev()`, `window.move({into_group="l"})` |
| Color picker | Omarchy `bindings/utilities.lua` | `hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("pkill hyprpicker \|\| hyprpicker -a"))` (currently commented out) |
| Magnifier | same | adjust `cursor.zoom_factor` via `hl.config` |
| Resize submap | Garuda `hyprland.lua` | `hl.define_submap("resize", …)`. SUPER+R is taken by screenshots, so pick another key |

**Scripts to copy into `bin/`:**

- `omarchy-launch-or-focus` (needs `jq`): focuses an existing WhatsApp, Claude,
  ChatGPT or X window instead of opening a duplicate on every press.
- `omarchy-capture-text`: OCR a region to the clipboard. Needs `tesseract`.
- `omarchy-capture-qr`: decode a QR code with `wl-copy --sensitive`. Needs `zbar`.

### Protect the compositor from OOM kills

Fedora's `systemd-oomd-defaults` monitors all of `user@.service`, compositor
included. Omarchy (`default/systemd/user/app.slice.d/10-oomd.conf`) limits
killing to apps:

```ini
# ~/.config/systemd/user/app.slice.d/10-oomd.conf
[Slice]
ManagedOOMMemoryPressure=kill
ManagedOOMSwap=kill
```

This only works if apps are launched with `uwsm app --`, so they land in
`app.slice`.

### Fontconfig

Omarchy's `default/fontconfig/conf.avail/50-omarchy.conf` maps `monospace` to
JetBrainsMono Nerd Font. It also aliases `system-ui`, `-apple-system` and
`BlinkMacSystemFont`, which fixes web UIs, and adds an emoji fallback. Add a
trimmed copy as `fontconfig/fonts.conf` and symlink it to
`~/.config/fontconfig/fonts.conf`.

### kitty (`kitty/kitty.conf`)

```conf
# Omarchy etc/xdg/kitty/kitty.conf: lets TUIs such as Claude Code distinguish Shift+Enter
map shift+enter send_text all \e[13;2u
map ctrl+insert copy_to_clipboard
map shift+insert paste_from_clipboard

# Garuda etc/skel/.config/kitty/kitty.conf
cursor_trail 1
cursor_trail_decay 0.15 0.5
cursor_trail_start_threshold 1
map ctrl+shift+u open_url_with_hints
```

Garuda also maps `scroll_to_prompt` and `new_os_window_with_cwd`.

### zsh (`.zshrc`)

The zinit config already covers syntax highlighting, autosuggestions, fzf-tab,
the OMZ git snippet, history options, eza and zoxide.
`PackageKit-command-not-found` handles command-not-found.

```zsh
# Plugin (CachyOS, Garuda)
zinit light zsh-users/zsh-history-substring-search

# Options (Garuda zshrc)
setopt autocd extendedglob auto_pushd pushd_ignore_dups
zstyle ':completion:*' rehash true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zcache

# Man pages through bat (CachyOS, Omarchy)
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Aliases (CachyOS / Garuda, translated to Fedora)
alias make="make -j$(nproc)"
alias ninja="ninja -j$(nproc)"
alias jctl='journalctl -p 3 -xb'
alias psmem='ps auxf | sort -nr -k 4 | head -10'
alias ip='ip -color'
alias wget='wget -c'
alias tarnow='tar -acf'
alias tb='nc termbin.com 9999'
alias ..='cd ..'
alias ...='cd ../..'
alias update='sudo dnf upgrade --refresh'
alias cleanup='sudo dnf autoremove'
alias rip='rpm -qa --last | head -50'
alias big="rpm -qa --qf '%{SIZE}\t%{NAME}\n' | sort -n | tail -30"

# Omarchy default/bash/aliases
open() { xdg-open "$@" >/dev/null 2>&1 & }
```

Omarchy also has an `ssh` wrapper (`default/bash/fns/ssh-reconnect`). After a
dropped connection it resets stuck terminal modes and reconnects. The reset is:

```sh
printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1004l\e[?1049l\e[?25h'
```

### SSH (`~/.ssh/config`)

From Omarchy `install/config/ssh-keepalive.sh`:

```sshconfig
Host *
  ServerAliveInterval 15
  ServerAliveCountMax 3
  ConnectTimeout 10
```

### Desktop entries and GTK

- **"Reboot to UEFI"** (`systemctl reboot --firmware-setup`) and
  suspend-then-hibernate entries (Garuda `garuda-common-settings`): add them to
  `desktop-apps/`.
- **GTK/libadwaita cursor** (Garuda `usr/bin/apply-gsettings`): match gsettings
  to the UWSM cursor variables with
  `gsettings set org.gnome.desktop.interface cursor-theme Adwaita` and
  `cursor-size 24`.
- **Share picker with window previews** (Omarchy `config/hypr/xdph.conf`,
  `hyprland-preview-share-picker`): AUR only; Fedora availability unverified.

### Only if you hit the problem

- WirePlumber Bluetooth A2DP auto-connect, or the ALSA soft-mixer for muffled
  Realtek audio (Omarchy `config/wireplumber/`)
- hypridle `after_sleep_cmd = hyprctl dispatch dpms on` (Garuda). Noctalia owns
  idle, so don't run both.
- hyprsunset identity profile (Omarchy), if not using Noctalia's night light

## 3. System-level ideas (need root)

### All-in-one option

this is a no go.
COPR `bieszczaders/kernel-cachyos-addons` packages CachyOS-Settings for
f43, f44, f45 and rawhide:

```sh
sudo dnf copr enable bieszczaders/kernel-cachyos-addons
sudo dnf swap zram-generator-defaults cachyos-settings
```

It installs everything below at once, including NVIDIA and SATA rules this
machine doesn't need. It also requires systemd-resolved. Individual drop-ins in
`/etc` give finer control.

### Memory and swap

| Tweak | Source | Fedora now | Apply | Risk |
| --- | --- | --- | --- | --- |
| zram zstd, larger size | CachyOS `zram-generator.conf` (`ram`), Omarchy `90-omarchy.conf` (`ram`) | 8G lzo-rle | `/etc/systemd/zram-generator.conf`: `[zram0]` `compression-algorithm = zstd`, `zram-size = ram / 2`, `swap-priority = 100` | Low |
| swappiness 150 (CachyOS/Omarchy) or 133 (Garuda) | `30-zram.rules`, `99-omarchy-sysctl.conf`, `99-sysctl-garuda.conf` | 10 (tuned) | custom tuned profile | **Medium** with HDD swap |
| `vm.page-cluster=0` | CachyOS, Omarchy | 3 | sysctl / tuned | Low for zram; hurts HDD swap |
| `vm.vfs_cache_pressure=50` | CachyOS, Omarchy | 100 | sysctl | Low |
| `vm.dirty_bytes=268435456`, `dirty_background_bytes=67108864`, `dirty_writeback_centisecs=1500` | CachyOS, Omarchy | ratios 40/10 | tuned `[sysctl]` | Low |
| `vm.watermark_boost_factor=0`, `watermark_scale_factor=125` | Omarchy | defaults | sysctl | Low |
| THP defrag `defer+madvise`, `khugepaged/max_ptes_none=409` | CachyOS `tmpfiles.d/thp.conf`, `thp-shrinker.conf` | madvise, 511 | `/etc/tmpfiles.d/` | Low |
| oomd pressure limit 50% for 20s | Omarchy `oomd.conf.d/10-omarchy.conf` | 60%/20s | `/etc/systemd/oomd.conf.d/` | Low; pairs with the app.slice drop-in |

With 62 GiB RAM, the gains from memory tuning are small.

### Kernel, network, scheduler

| Tweak | Source | Fedora now | Apply | Risk |
| --- | --- | --- | --- | --- |
| `net.ipv4.tcp_mtu_probing=1` | Omarchy (fixes flaky SSH) | 0 | `/etc/sysctl.d/90-net.conf` | Low |
| `net.core.default_qdisc=fq`, `tcp_congestion_control=bbr` | Omarchy | cubic | same file | Low |
| `net.core.netdev_max_backlog=4096` | CachyOS | 1000 | same file | Low |
| `kernel.nmi_watchdog=0` | CachyOS, Garuda | 1 | sysctl | Low (lose hard-lockup detection) |
| `kernel.kptr_restrict=2`, `kernel.printk=3 3 3 3` | CachyOS | 0; `3 4 1 7` | sysctl | Low |
| `kernel.sysrq=1` | Garuda | 16 | sysctl | Low |
| I/O schedulers: bfq HDD, mq-deadline SATA SSD, kyber/none NVMe | CachyOS `60-ioschedulers.rules` (Omarchy uses kyber everywhere) | bfq on `sda` SSD too | `/etc/udev/rules.d/60-ioschedulers.rules` | Low; main change is `sda` to mq-deadline |
| Load `ntsync` at boot | CachyOS `modules-load.d/ntsync.conf` | not loaded | `echo ntsync \| sudo tee /etc/modules-load.d/ntsync.conf` | Low; helps Wine/Proton only |
| Blacklist `sp5100_tco` watchdog | CachyOS `modprobe.d/blacklist.conf` | loaded | `/etc/modprobe.d/blacklist-watchdog.conf`, then `dracut -f` | Low |
| sched-ext (`scx_lavd`, `bpfland`) | CachyOS wiki `configuration/sched-ext.mdx` | supported, disabled | COPR addons `scx-scheds scx-tools`; `/etc/scx_loader/config.toml`; `systemctl enable --now scx_loader` | Medium; the kernel falls back to EEVDF on crash. Power-profile switching needs CachyOS's power-profiles-daemon, which conflicts with tuned-ppd |
| CachyOS kernel (BORE, BBRv3, ADIOS) | COPR `bieszczaders/kernel-cachyos` | stock | `dnf install kernel-cachyos kernel-cachyos-devel-matched` | Medium; lags Fedora (7.2.3 vs 7.2.5); `-lto` can break akmods |
| ananicy-cpp + CachyOS rules | COPR addons | not installed | `dnf install ananicy-cpp cachyos-ananicy-rules` | Medium; **do not combine with gamemode** (installed) |
| Game performance wrapper | CachyOS `usr/bin/game-performance` | no `powerprofilesctl` | use `gamemoderun %command%` | Low |

### systemd

| Tweak | Source | Fedora now | Apply | Risk |
| --- | --- | --- | --- | --- |
| Stop timeouts (CachyOS 15s/10s, Garuda 10s, Omarchy 5s) | `system.conf.d/00-timeout.conf`, `user.conf.d/` | 90s | `/etc/systemd/system.conf.d/`, `/etc/systemd/user.conf.d/`; use 10–15s | Medium; 5s can kill podman or databases before they flush |
| NOFILE `65536:524288` | Omarchy `20-omarchy-nofile.conf` | 524288 hard | same dirs | Low |
| Delegate `cpuset` to user services | CachyOS `user@.service.d/delegate.conf` | cpu, io, memory, pids | `/etc/systemd/system/user@.service.d/` | Low |
| Journal cap (CachyOS/Garuda 50M) | `journald.conf.d/00-journal-size.conf` | no cap, 158M used | `/etc/systemd/journald.conf.d/`; 500M is safer for debugging | Low |
| Coredumps kept 3 days | CachyOS, Garuda `tmpfiles.d/coredump.conf` | default | `/etc/tmpfiles.d/coredump.conf`: `e /var/lib/systemd/coredump - - - 3d` | Low |
| resolved `LLMNR=no`, `MulticastDNS=no` | Omarchy `resolved.conf.d/10-disable-multicast.conf` | LLMNR=resolve | `/etc/systemd/resolved.conf.d/` | Low |
| logind `InhibitDelayMaxSec=15` + lock before suspend | Omarchy `logind.conf.d/20-inhibit-delay.conf`, `bin/omarchy-system-sleep-lock` | unverified whether Noctalia locks before suspend | test with `systemctl suspend` | Low |
| Unmount gvfs FUSE before suspend | Omarchy `system-sleep/unmount-fuse` | n/a | `/usr/lib/systemd/system-sleep/` (whether `/etc` is honored is unverified) | Low; only if suspend fails |
| Disable `thermald` | CachyOS wiki (Intel only) | enabled on AMD | `systemctl disable --now thermald` | Low |

### Other

| Tweak | Source | Apply | Risk |
| --- | --- | --- | --- |
| Snapshots before dnf transactions | Omarchy `install/config/snapper.sh`, Garuda | `snapper`, a dnf5 snapshot plugin, `grub-btrfs` (COPR); package names on F44 unverified | Medium effort, high value |
| Monthly btrfs scrub | Garuda btrfsmaintenance | a timer; `fstrim.timer` is already enabled; Fedora `btrfsmaintenance` availability unverified | Low |
| Audio: HDA power-save off on AC, `@audio` rtprio limits, hpet/rtc permissions | CachyOS `20-audio-pm.rules`, `limits.d/20-audio.conf` | `/etc/udev/rules.d/`, `/etc/security/limits.d/` | Low; only for crackles or pro audio |
| sudo `Defaults pwfeedback`, `passwd_tries=10` | Garuda, Omarchy | `visudo -f /etc/sudoers.d/…` | Low; cosmetic |
| `usbcore autosuspend=-1` | Omarchy | `/etc/modprobe.d/` | Low; only if USB devices drop |
| `blacklist pcspkr` | Garuda | `/etc/modprobe.d/` | Low |
| `tcp_fin_timeout=5`, `sched_cfs_bandwidth_slice_us=3000` | Garuda (SteamOS values) | sysctl | Low; gaming only |
| LocalSend port | Omarchy `install/config/firewall.sh` (ufw) | `firewall-cmd --permanent --add-port=53317/{tcp,udp}` | Low |

## 4. Skip on Fedora

| Item | Reason |
| --- | --- |
| Garuda `performance-tweaks` (governor, ASPM, amdgpu `power_dpm_state`, `ppfeaturemask`) | tuned already sets governor/EPP; more heat and power for little gain |
| Omarchy passwordless keyring and SDDM `pam_gnome_keyring` removal | Built for autologin; GDM PAM unlock is what the `gnome-libsecret` setup relies on |
| Garuda polkit rule (wheel mounts/power with no prompt) | Fedora already allows these for the active local session; weakens security |
| ufw, ufw-docker, Docker `daemon.json` | firewalld is active; podman is used |
| waybar, wofi, walker, mako, swaync, nwg-drawer, wpaperd, swaylock, cliphist autostart, Omarchy menu/theme system | Noctalia covers bar, launcher, notifications, wallpaper, clipboard and lock |
| NVIDIA modprobe/udev rules and env | AMD GPU |
| `modprobe.d/amdgpu.conf` (si/cik), `amdgpu ppfeaturemask` | Old GPUs / overclocking only |
| `blacklist mei mei_me`, thermald | Intel only |
| x86-64-v4 builds | 5900X is v3 |
| `split_lock_mitigate=0` | No `split_lock_detect` on this CPU |
| `kernel.unprivileged_userns_clone`, `fs.file-max` | Arch/zen-only sysctl; file-max already maximal |
| `vm.max_map_count` | Already 1048576 on Fedora |
| SATA ALPM / hdparm rules | Small gain; `-S 0` keeps the HDD spinning forever |
| timesyncd config | Fedora uses chronyd |
| RCU Lazy, laptop items (lid, battery, backlight, touchpad, Wi-Fi powersave) | Desktop |
| Zswap instead of zram | Fedora defaults to zram; only if the HDD swap should back zswap |
| pacman/AUR aliases, rate-mirrors, pkgfile, limine, mkinitcpio, plymouth/SDDM themes, `omarchy-update`, `garuda-update` | Arch-specific; Fedora uses dnf5, grub2, dracut, GDM |
| Proton-CachyOS, wine-cachyos | Steam not installed |
| `preload` | Not packaged for Fedora; unmaintained |
| `SDL_VIDEODRIVER=wayland` globally | Breaks older SDL games |
| mpv config | mpv not installed; `profile=gpu-hq` is deprecated |
| fcitx5 IME env, XCompose files | Not used |
| `NetworkManager-wait-online` mask | Already disabled |

## 5. Recommended order

1. **Fix the bugs in section 1.** About 10 minutes; removes real breakage.
2. **Launch-or-focus for web apps, and `uwsm app --` on all launches.** Stops
   duplicate windows and puts apps in `app.slice`.
3. **`app.slice.d/10-oomd.conf`.** A runaway browser can no longer take down
   the session.
4. **1Password `no_screen_share` and hidden sharing indicators.**
5. **Multi-monitor binds, fake fullscreen and pop-out.**
6. **Hyprland misc/cursor/input defaults**, especially
   `allow_session_lock_restore`.
7. **`fontconfig/fonts.conf`.**
8. **Network sysctl, SSH keepalive and the ssh reconnect wrapper.**
9. **Custom tuned profile + zstd zram**, after deciding what to do with the HDD
   swap.
10. **Snapper snapshots on the btrfs root.**

Honorable mentions: OCR/QR capture binds, kitty `shift+enter` and cursor trail,
Noctalia bar blur, resize submap, `jctl`/`psmem` aliases, `ntsync` autoload,
disabling thermald.

## 6. Applied on 2026-09-16

Everything below was validated on this machine (syntax checks, `hyprctl
configerrors`, `hyprctl getoption`, fresh interactive zsh in a pseudo-terminal)
and then reviewed for security and regressions.

### Bugs from section 1

All fixed. `electron-flags.conf` was removed from the repo and `~/.config`,
and the README install steps were updated.

### Session environment

| Variable | Result |
| --- | --- |
| `_JAVA_AWT_WM_NONREPARENTING=1` | Applied |
| `ELECTRON_OZONE_PLATFORM_HINT=wayland` | Applied, then **rolled back**: only Postman (Electron 37.10) reads it and would switch to native Wayland. VS Code, Cursor, Devin, 1Password (Electron 42), Slack (44) and ChatGPT ignore it |
| `TERMINAL=kitty` | Applied (`xdg-terminal-exec` is not installed) |
| `EDITOR=nvim`, `VISUAL=nvim` | Applied; replaces Fedora's `nano` default |
| `xdg-terminals.list` (`kitty.desktop`) | Added; takes effect after `sudo dnf install xdg-terminal-exec` |
| `HYPRCURSOR_SIZE` | Skipped: no hyprcursor themes installed |
| `MOZ_DBUS_REMOTE` | Skipped: Firefox 155 is Wayland-native |
| `MESA_SHADER_CACHE_MAX_SIZE` | Skipped: no gaming; cache is 15M |

### Hyprland

| Change | Result |
| --- | --- |
| `allow_session_lock_restore`, `disable_splash_rendering`, `cursor.hide_on_key_press`, `cursor.warp_on_change_workspace = 1`, `binds.hide_special_on_workspace_change` | Applied |
| `input.repeat_rate = 40`, `repeat_delay = 250`, `numlock_by_default` | Applied |
| `focus_on_activate` | Applied, then **reverted** in the security review: focus stealing can redirect typed passwords |
| `persistent_size` for floating windows, `xdg_tag` game rule | Applied |
| 1Password `no_screen_share` | Applied (without float/center) |
| Sharing indicator to `special silent` | Applied, restricted to Chrome/Chromium/Brave titles `… is sharing your screen/a window/a tab` |
| slurp `selection` layer rule | Applied |
| Noctalia layer rule (blur, `no_anim`, `blur_popups`) | Applied with `ignore_alpha = 0.2`, because the bar is at `background_opacity = 0.5` |
| Firefox opacity rule | Fixed: Fedora's class is `org.mozilla.firefox` |
| `anr_missed_pings`, `on_focus_under_fullscreen`, `dwindle.force_split`, `render.direct_scanout`, `kb_options`, tag-based opacity | Skipped |

### OOM protection

Fedora's `/usr/lib/systemd/user/slice.d/10-oomd-per-slice-defaults.conf` makes
every user slice, including the user manager root, a memory-pressure monitor,
so Omarchy's `app.slice` drop-in alone does not protect the compositor.

- `systemd/user/app.slice.d/10-oomd.conf`: Omarchy's drop-in (adds swap kill)
- `systemd/user/wayland-wm@hyprland.desktop.service.d/10-oomd.conf`:
  `ManagedOOMPreference=omit`; verified `user.oomd_omit="1"` on the cgroup

### Fontconfig

`fontconfig/fonts.conf` (DTD-valid), symlinked as `~/.config/fontconfig`.
`monospace` resolves to JetBrainsMono Nerd Font; `system-ui` and
`-apple-system` resolve to Noto Sans.

### kitty

| Change | Result |
| --- | --- |
| `shift+enter send_text all \e[13;2u` | Applied; `.zshrc` binds `^[[13;2u` to `accept-line`. Other shells (bash, remote) show `[13;2u` |
| `ctrl+insert` / `shift+insert` clipboard, `ctrl+shift+n new_os_window_with_cwd`, cursor trail | Applied |
| `ctrl+shift+u open_url_with_hints` | Skipped: replaces Unicode input; `ctrl+shift+e` already opens URL hints |

### zsh

| Change | Result |
| --- | --- |
| zsh-history-substring-search (Up/Down) | Applied, pinned |
| `autocd`, `auto_pushd`, `pushd_ignore_dups`, completion `rehash` and cache | Applied |
| bat `MANPAGER` | Applied with `MANROFFOPT=-c` (otherwise headings show `1mNAME0m`), only when `bat` exists |
| `make`, `jctl`, `psmem`, `tarnow`, `..`, `...`, `update`, `cleanup`, `rip`, `big`, `open()` | Applied; `open` uses `&!` |
| `ip` alias | Applied as `ip -color=auto` (`-color` put escape codes into pipes) |
| `extendedglob` | Skipped: breaks `git reset HEAD^` |
| `tb` (termbin) | Skipped: uploads to a public plaintext paste site |
| `wget -c` | Skipped: silently corrupts changed downloads |
| `ninja -j` | Skipped: ninja is already parallel |
| `ssh` alias | Added: `TERM=xterm-256color` inside kitty, because remote hosts lack kitty's terminfo after removing the global `TERM` override |
| `.tmux.conf` | Added `xterm-kitty:RGB` terminal feature for the same reason |

### Security review notes

- No secrets, keys or tokens in the tree or git history; no `curl | sh`.
- Pre-existing and unchanged: `hypr/xdph.conf` `allow_token_by_default = true`
  (approved screen-share apps can capture again without asking),
  tmux `set-clipboard on`, user directories ahead of system `PATH` (only the JDK
  shadows system binaries).
- Removing `xhost +SI:localuser:root` stops root X11 GUI apps from opening.
- Salesforce CLI: log out and back in before re-authenticating, so every `sf`
  consumer uses `SF_USE_GENERIC_UNIX_KEYCHAIN`
  (see [Salesforce CLI keyring](salesforce-cli-keyring.md)).

### Not applied

Section 3 (system-level) changes need root and were not applied.

## Unverified

- Whether tuned's profile overrides `/etc/sysctl.d` values after boot
- Whether vendor Electron apps (Slack, Postman) ever read `electron-flags.conf`
- Per-app Electron versions for the ozone hint
- `hyprland-preview-share-picker` availability on Fedora
- Whether Noctalia locks before suspend. noctalis is working as expected.
- Whether `/etc/systemd/system-sleep/` is honored
- F44 package names for the snapper dnf plugin and btrfsmaintenance
- Garuda "Temeraire" release details (third-party
  [article](https://ettayeb.fr/en/linux/garuda-linux-temeraire-cachyos-kernel/))
