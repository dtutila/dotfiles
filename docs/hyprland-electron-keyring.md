# GNOME Keyring for Electron apps under Hyprland

## Scope

This note records the recommended configuration for making Chromium/Electron
applications use GNOME Keyring (`gnome-libsecret`) in the UWSM-managed
Hyprland session.

The login keyring itself is already working:

- `gnome-keyring`, `gnome-keyring-pam`, and `libsecret` are installed.
- `gnome-keyring-daemon.service` and its socket are enabled and running.
- GDM's PAM stack starts the daemon and unlocks `login.keyring`.
- The current `Login` collection reports `Locked=false`.

The remaining problem is backend detection in Chromium/Electron applications,
not keyring startup or unlocking.

## Why Electron misses the keyring

The current session exports:

```text
XDG_CURRENT_DESKTOP=Hyprland
```

Electron's synchronous `safeStorage` backend detection does not recognize
Hyprland. It recognizes values including `GNOME`, or accepts the explicit
argument:

```text
--password-store=gnome-libsecret
```

There is no supported global `ELECTRON_*` environment variable that injects
this command-line argument. An `electron-flags.conf` file is also not universal:
it only works with distribution launchers that explicitly read it. The apps on
this system bundle their own Electron runtimes, so such a file would not cover
VS Code, Slack, or Postman.

References:

- [Electron `safeStorage`](https://www.electronjs.org/docs/latest/api/safe-storage)
- [Electron environment variables](https://www.electronjs.org/docs/latest/api/environment-variables)
- [Chromium Linux password storage](https://chromium.googlesource.com/chromium/src.git/+/master/docs/linux/password_storage.md)
- [Chromium desktop detection](https://chromium.googlesource.com/chromium/src/+/master/base/nix/xdg_util.cc)

## Recommended session-wide configuration

Advertise GNOME as a secondary desktop identity while retaining Hyprland as
the primary identity.

For this user, create:

```text
~/.config/uwsm/env-hyprland
```

with:

```sh
export XDG_CURRENT_DESKTOP=Hyprland:GNOME
```

For all users of UWSM-managed Hyprland sessions, use this file instead:

```text
/etc/xdg/uwsm/env-hyprland
```

UWSM sets the session desktop identity before sourcing `env-hyprland`, then
exports the resulting environment to applications, systemd user services, and
D-Bus activation. Do not change `XDG_SESSION_DESKTOP`; it should remain
`Hyprland`.

After applying the configuration, perform a complete logout and login. Merely
reloading Hyprland will not update applications and services that are already
running.

The order is intentional. Chromium checks each colon-separated desktop name,
so it skips the unknown `Hyprland` value and then recognizes `GNOME`. Components
that choose configuration from the first desktop identity can continue choosing
Hyprland.

## Flatpak Secret portal

Modern Electron provides asynchronous safe-storage APIs that prefer
`org.freedesktop.portal.Secret` in sandboxed environments. The installed
Hyprland portal configuration currently selects only `hyprland;gtk`, so it does
not expose the Secret portal.

For this user, the corresponding portal configuration would be:

```ini
# ~/.config/xdg-desktop-portal/hyprland-portals.conf
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.Secret=gnome-keyring
```

For every user, place the same content at:

```text
/etc/xdg/xdg-desktop-portal/hyprland-portals.conf
```

References:

- [XDG Desktop Portal configuration](https://flatpak.github.io/xdg-desktop-portal/docs/portals.conf.html)
- [Secret portal](https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.Secret.html)

This is preferable to granting every Flatpak direct access to
`org.freedesktop.secrets`: the portal returns an application-specific secret
instead of exposing the user's general Secret Service to every sandbox.

### Installed Flatpak observations

- Slack already has direct `org.freedesktop.secrets` access in its Flatpak
  metadata.
- Postman does not have that direct D-Bus permission.
- Both currently receive `XDG_CURRENT_DESKTOP=Hyprland` from the host session.

The composite desktop identity should fix backend detection for Slack. Modern
Electron applications can use the Secret portal once configured. If an older
Flatpak still uses synchronous libsecret and cannot use the portal, grant direct
Secret Service access only to that application after reviewing the security
tradeoff. For Postman, the narrowly scoped command would be:

```sh
flatpak override --user \
  --talk-name=org.freedesktop.secrets \
  com.getpostman.Postman
```

Do not apply this override globally to all Flatpaks.

## App-specific fallback

If adding `GNOME` to the session identity causes unwanted desktop behavior,
prefer app-specific configuration instead.

### VS Code

VS Code officially supports this in `~/.vscode/argv.json`:

```json
{
  "password-store": "gnome-libsecret"
}
```

Reference: [VS Code keyring configuration](https://code.visualstudio.com/docs/configure/settings-sync#_configure-the-keyring-to-use-with-vs-code)

### Other Electron applications

Append this argument to each application's launcher:

```text
--password-store=gnome-libsecret
```

For packaged desktop applications, create a user-owned desktop-entry override
under `~/.local/share/applications` rather than modifying files under
`/usr/share/applications` or Flatpak's exported application directory. Package
updates can replace the latter files.

## Existing dotfiles issue

`hypr/config/defaults.lua` already includes `--password-store=gnome-libsecret`,
but only for commands named `chromium`. This Fedora installation currently has
Google Chrome installed and no `chromium` executable, so those launch commands
do not cover the installed browser. They also cannot affect Electron apps.

## Tradeoffs

Adding `GNOME` to `XDG_CURRENT_DESKTOP` is the broadest practical workaround,
but it is not equivalent to a global Electron-only flag. Other desktop-aware
software can also see the additional identity.

On the current Fedora installation, GNOME-only XDG autostart entries include
GNOME Keyring launchers, LocalSearch, and GNOME disk notifications. Some may be
conditioned off, while others may start. Keeping `Hyprland` first preserves the
existing Hyprland portal configuration, but the additional autostarts should be
reviewed after the first login.

## Verification

After logging in again, confirm the session identity:

```sh
systemctl --user show-environment | grep '^XDG_CURRENT_DESKTOP='
```

Expected result:

```text
XDG_CURRENT_DESKTOP=Hyprland:GNOME
```

Confirm what a Flatpak receives:

```sh
flatpak run --command=sh com.slack.Slack -c \
  'printf "%s\n" "$XDG_CURRENT_DESKTOP"'
```

Confirm that the Secret portal is exposed:

```sh
busctl --user introspect \
  org.freedesktop.portal.Desktop \
  /org/freedesktop/portal/desktop \
  org.freedesktop.portal.Secret
```

Finally, start each affected application from a fresh process. Existing
processes retain their old environment and backend selection.
