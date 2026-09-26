# zsh plugin pins

## Why

zinit normally installs and updates plugins from each repository's default
branch. A compromised or broken upstream commit would run in every new shell.
`.zshrc` pins zinit, every plugin and every snippet to a reviewed commit SHA.
Commit SHAs are used instead of tags because tags can be moved.

## Pinned versions

Pinned and reviewed on 2026-09-16. Every commit is on the upstream default
branch and was the version already running on this machine.

| Component | Repository | Pinned commit | Relation to last release |
| --- | --- | --- | --- |
| zinit | [zdharma-continuum/zinit](https://github.com/zdharma-continuum/zinit) | `98bcb79c3d7aae25a81e00e9795ebf7042e2bd6e` | = `v3.16.0` (`v3.17.0` exists, not reviewed) |
| powerlevel10k | [romkatv/powerlevel10k](https://github.com/romkatv/powerlevel10k) | `3308262dfbd743b6e1d3956a2b5572f7a049d692` | `v1.20.0` + 94 commits |
| fast-syntax-highlighting | [zdharma-continuum/fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting) | `4672ad5dd9ad68a7effc1476d65afb7c584ce2b3` | `v1.56` + 3 commits |
| zsh-autosuggestions | [zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | `85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5` | `v0.7.1` + 6 commits (docs only) |
| zsh-history-substring-search | [zsh-users/zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search) | `14c8d2e0ffaee98f2df9850b19944f32546fdea5` | `v1.1.0` + 14 commits |
| zsh-completions | [zsh-users/zsh-completions](https://github.com/zsh-users/zsh-completions) | `8cd3bd78e8b1f17271cfdd8269074e5557d8d7b8` | `0.36.0` + 176 commits (completion definitions) |
| fzf-tab | [Aloxaf/fzf-tab](https://github.com/Aloxaf/fzf-tab) | `24105b15714bfec37989ed5c5b6e60f572253019` | `v1.3.0` + 3 commits |
| OMZ `git` plugin | [ohmyzsh/ohmyzsh](https://github.com/ohmyzsh/ohmyzsh) `plugins/git/git.plugin.zsh` | `91ad6c5c4ce7727500662e093e41ac421527e23a` | no releases; file sha256 `b7e899c6…2917` |
| OMZ `command-not-found` plugin | same, `plugins/command-not-found/command-not-found.plugin.zsh` | `a8afe14b93051178264db802d964c7f31a552e8d` | no releases; file sha256 `173a51f1…dd48` |

The Oh My Zsh snippets load from `raw.githubusercontent.com/ohmyzsh/ohmyzsh/<sha>/…`
URLs under the ids `omz-git` and `omz-command-not-found`. The downloaded files
match the previously installed, unpinned copies byte for byte.

## Review performed

- **Provenance:** each pinned commit is reachable from the upstream default
  branch (`git branch -r --contains`).
- **Commits since the last release:** reviewed the log and diff for each plugin.
  They contain bug fixes, documentation and completion updates. No new network
  access or command execution was added. The `curl`/`sudo` strings in
  zsh-completions are completion descriptions.
- **Static scan** of runtime files for `curl`, `wget`, `/dev/tcp`, `base64 -d`,
  `sudo`, `eval $(…)` and SSH key paths. Findings:
  - **fast-syntax-highlighting:** on load, if `$FAST_WORK_DIR/secondary_theme.zsh`
    is missing, it downloads `share/free_theme.zsh` from the **unpinned `master`
    branch** and later `source`s it. `.zshrc` sets `FAST_WORK_DIR` and an
    `atinit` hook copies the file from the pinned checkout first, so the
    download never runs. The cached copy was verified identical to the pinned
    file.
  - **powerlevel10k:** `gitstatus/install` downloads the `gitstatusd` binary
    from GitHub releases (fallback: gitee), using `curl -k`. The download is
    accepted only if it matches the sha256 recorded in `gitstatus/install.info`,
    so pinning the plugin commit also pins the binary.
  - **zinit, zsh-autosuggestions, fast-syntax-highlighting tests:** `sudo`/`curl`
    appear only in Docker, CI and test scripts that are never sourced.
- Not done: signature verification (upstream tags and commits are not signed
  with keys available here) and a line-by-line audit of whole code bases.

## Enforcement in `.zshrc`

- zinit is cloned and checked out at `ZINIT_COMMIT`. Every shell compares
  `.git/HEAD` with the pin and prints a yellow warning when they differ.
- Plugins use `ver"<sha>"`. zinit checks that commit out on install, and
  `zinit update` runs `git pull --ff-only origin <sha>`, which keeps the pin.
- Existing checkouts under `~/.local/share/zinit/plugins` were moved to the
  pinned commits (detached HEAD, no local changes).

Do not run `zinit self-update`; it moves zinit to the tip of `main`.

## Updating a pin

1. Fetch and review upstream changes:

   ```sh
   d=~/.local/share/zinit/plugins/zsh-users---zsh-autosuggestions
   git -C "$d" fetch --tags origin
   git -C "$d" log --oneline <old-sha>..origin/master
   git -C "$d" diff <old-sha>..<new-sha> -- . ':!test' ':!tests'
   ```

2. Scan the diff for new network access, `eval`, `sudo` or downloaded code, and
   confirm the new commit is on the default branch.
3. Update the SHA in `.zshrc` and in the table above, then
   `git -C "$d" checkout <new-sha>`.
4. For an Oh My Zsh snippet, change the SHA in the URL and delete
   `~/.local/share/zinit/snippets/<id>` so it downloads again.
5. For zinit itself, update `ZINIT_COMMIT` and run
   `git -C ~/.local/share/zinit/zinit.git checkout <new-sha>`.
