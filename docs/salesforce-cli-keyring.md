# Salesforce CLI `AuthDecryptError` on Fedora

## Symptom

Every stored org fails to load:

```text
AuthDecryptError: Failed to decipher auth data. reason: Unsupported state or unable to authenticate data.
```

`sf org list` logs `Error decrypting <username>` for each org. The same setup
never showed this on CachyOS.

## Root cause

### How `sf` stores its key on Linux

`@salesforce/core` encrypts tokens in `~/.sfdx/<username>.json` with AES-GCM.
The key is stored in one of two places (`lib/crypto/keyChain.js`):

- If `/usr/bin/secret-tool` exists and runs: the Secret Service
  (`secret-tool lookup user local domain sfdx`).
- Otherwise, or with `SF_USE_GENERIC_UNIX_KEYCHAIN=true`: `~/.sfdx/key.json`.

When the lookup exits with code 1, `sf` treats it as "no key exists", generates a
new random key and stores it over the old entry (`lib/crypto/crypto.js`,
`lib/crypto/keyChainImpl.js`). It only retries when stderr contains
`invalid or unencryptable secret`. Any other failure silently replaces the key,
and every existing auth file becomes undecryptable.

### Why the lookup fails on Fedora

Lookups against gnome-keyring intermittently return no secret, with exit code 1
and no error output, even though the item exists and the keyring is unlocked.

Measurements on this machine (gnome-keyring 50.0, libsecret 0.21.7, Fedora 44):

| Client / transfer | Lookups | Misses |
| --- | --- | --- |
| `secret-tool lookup`, sequential | 300 | 3 |
| libsecret (PyGObject), new connection each time | 1000 | 2 |
| Raw D-Bus `SearchItems` | 400 | 0 |
| Raw D-Bus `GetSecrets`, `plain` session | 1000 | 0 |
| Python `secretstorage`, encrypted DH session (own crypto) | 1000 | 0 |

The item is always found. Only libsecret's encrypted secret transfer
(`dh-ietf1024-sha256-aes128-cbc-pkcs7`) loses the value, roughly 0.2–1% of the
time. An independent DH client against the same daemon never fails, so the bug
is in libsecret's crypto path, not in gnome-keyring. The rate is close to
1/256, which suggests a leading-zero mismatch when deriving the DH shared key.
That part is a hypothesis, not confirmed.

### Why CachyOS was not affected

The distributions build libsecret with different crypto backends:

| | libsecret crypto | gnome-keyring crypto |
| --- | --- | --- |
| Arch / CachyOS | libgcrypt | libgcrypt |
| Fedora 44 | GnuTLS (`-Dcrypto=gnutls`) | libgcrypt |

Only Fedora's GnuTLS build pairs a different DH implementation with
gnome-keyring. CachyOS Hyprland may also have had no Secret Service running, in
which case `sf` used `~/.sfdx/key.json` anyway.

References:

- [Arch libsecret PKGBUILD](https://gitlab.archlinux.org/archlinux/packaging/packages/libsecret/-/raw/main/PKGBUILD)
- [Fedora libsecret.spec](https://src.fedoraproject.org/rpms/libsecret/raw/rawhide/f/libsecret.spec)

### What triggered the overwrites

On 2026-09-16 the `sfdx` keyring item was replaced twice (the journal shows
`asked to register item /org/freedesktop/secrets/collection/login/17, but it's already registered`):

- **06:17:23**: Devin started at 06:17:19. `salesforce.salesforcedx-vscode-services`
  activated at 06:17:22.6.
- **14:11:50**: an agent session was running a loop of `sf sobject describe` /
  `sf data query`. The calls before it succeeded, and every call after it failed.

Many `sf` calls in a row, or several Salesforce extensions activating together,
make a 1% miss likely. Devin logs show the same failure on 2026-09-08.

The dotfiles keyring changes (`--password-store=gnome-libsecret`,
`XDG_CURRENT_DESKTOP=Hyprland:GNOME`) only affect Chromium/Electron backend
selection. They did not cause this.

## Applied fix

`sf` is forced to use the file-based key everywhere:

- `uwsm/env-hyprland`: covers the whole session (editors, extensions, agents).
- `.zshrc`: covers shells that do not inherit the session environment.

```sh
export SF_USE_GENERIC_UNIX_KEYCHAIN=true
```

Every `sf` consumer must see the same value. A process without it would go back
to the keyring and use a different key.

Tradeoff: the key lives in `~/.sfdx/key.json` (mode `600`) rather than in the
keyring. Disk encryption covers it at rest.

### After applying

1. Log out and back in so UWSM exports the variable to all apps.
2. Re-authenticate. Tokens encrypted with the lost key cannot be recovered:

   ```sh
   sf org logout --all --no-prompt
   sf org login web --alias <alias> --instance-url <url>
   ```

3. Optionally remove the stale keyring item:

   ```sh
   secret-tool clear user local domain sfdx
   ```

## Verification

```sh
systemctl --user show-environment | grep SF_USE_GENERIC_UNIX_KEYCHAIN
ls -l ~/.sfdx/key.json          # expect -rw-------
sf org list
```

Reproduce the libsecret misses (the key must exist):

```sh
f=0; for i in $(seq 300); do
  secret-tool lookup user local domain sfdx >/dev/null || f=$((f+1))
done; echo "misses=$f"
```

## Alternatives

### Retry wrapper, keeping the key in the keyring

`sf` honours `SFDX_SECRET_TOOL_PATH`. A wrapper that retries lookups makes a
false "not found" practically impossible:

```sh
#!/usr/bin/env bash
[ "$1" = lookup ] || exec /usr/bin/secret-tool "$@"
for i in 1 2 3 4 5; do
  /usr/bin/secret-tool "$@" && exit 0
  sleep 0.1
done
exit 1
```

Set `SFDX_SECRET_TOOL_PATH` to it instead of `SF_USE_GENERIC_UNIX_KEYCHAIN`.
This only protects `sf`.

### Rebuild libsecret with libgcrypt

The Fedora spec already has a switch for this. It fixes every libsecret client,
but you then maintain a local package:

```sh
fedpkg clone -a -b f44 libsecret && cd libsecret
fedpkg sources
sudo dnf builddep libsecret.spec
rpmbuild -ba --define "_sourcedir $PWD" --without gnutls libsecret.spec
sudo dnf install ~/rpmbuild/RPMS/x86_64/libsecret-*.rpm
sudo dnf versionlock add libsecret
```

### Replacing the daemon

KeePassXC or KWallet as Secret Service would not help. Clients still reach them
through the same GnuTLS libsecret. gnome-keyring itself behaves correctly.

### Upstream

Report to Fedora or [libsecret](https://gitlab.gnome.org/GNOME/libsecret): the
GnuTLS DH session intermittently returns a NULL secret against gnome-keyring,
with the reproduction loop above.

## Omarchy and CachyOS keyring setups

- **Omarchy**: gnome-keyring + libsecret (`install/omarchy-base.packages`). It
  creates a passwordless, never-locking `Default_keyring`
  (`install/user/default-keyring.sh`) and pins browsers and VS Code to
  `gnome-libsecret`.
- **CachyOS Hyprland**: the current `cachyos-hypr-noctalia` ships no keyring
  configuration. The older `cachyos-hyprland-settings` 1.2.6 added gnome-keyring
  as a dependency, which caused new-keyring prompts on boot. The CachyOS wiki
  mentions KWallet as the installed default, with gnome-keyring as an option.
- Both run on Arch's libgcrypt build of libsecret, so neither hits this bug.

References:

- [basecamp/omarchy](https://github.com/basecamp/omarchy)
- [cachyos-hypr-noctalia issue #38](https://github.com/CachyOS/cachyos-hypr-noctalia/issues/38)
- [CachyOS wiki: Hyprland](https://wiki.cachyos.org/configuration/desktop_environments/hyprland/)
