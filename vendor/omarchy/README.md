# Vendored Omarchy shell

This is a read-only fork of Omarchy's desktop shell. The NixOS integration
ships Omarchy's own QML, themes, config defaults, and helper commands instead
of reimplementing its UI. See
[ADR 0006](../../docs/adr/0006-fork-omarchy-shell.md),
[spec 0003](../../docs/specs/0003-omarchy-fork-rewire.md), and
[plan 0003](../../docs/plans/0003-omarchy-fork-rewire.md).

The shipped shell is `vendor/omarchy/shell`. The old independent shell is
archived at `legacy/independent-shell` and is not loaded by the supervisor.

## Upstream pin

| | |
|---|---|
| Source | https://github.com/omacom/omarchy |
| Branch at capture | `quattro` |
| Commit | `255acd9b9f752478365a1207f499e5d558bf7f75` |
| Version | `4.0.0.alpha` (`vendor/omarchy/version`) |
| Captured | 2026-11-11 |

The pin is a commit, not a branch. Do not follow `quattro` automatically; a
new upstream commit is a deliberate sync.

## What is copied

Only these paths are copied from the upstream checkout at the pin:

- `shell/` -> `vendor/omarchy/shell/` (the shipped Quickshell config)
- `themes/tokyo-night/` -> `vendor/omarchy/themes/tokyo-night/`
- `config/omarchy/` -> `vendor/omarchy/config/omarchy/` (fallback user config)
- `default/` -> `vendor/omarchy/default/` (templates, theme defaults, input
  methods, and data used by the shell and helpers)
- `bin/` -> `vendor/omarchy/bin/` (the `omarchy-*` helper commands)
- `LICENSE` and `version`

The rest of the upstream repository is not copied. `OMARCHY_PATH` in the
supervisor points at this directory, so helpers resolve `shell/`, `default/`,
and `bin/` exactly as they do upstream.

## License and provenance

Omarchy is MIT-licensed. The upstream notice is preserved verbatim in
[`LICENSE`](./LICENSE):

> Copyright (c) David Heinemeier Hansson

The vendored files are a fork, not an independent implementation: keep the
notice with the tree, and describe the modifications in the commit or PR that
introduces them. Our own integration code (the supervisor, module, config,
tests, and docs) remains ours.

## Local modifications and patches

At this pin the vendored files are unmodified. NixOS adaptation lives outside
this directory:

| Area | Location | What changes |
|---|---|---|
| Quickshell build | `modules/pkgs/quickshell.nix` | Pins `0.3.2.r7.g2b4501a` and applies the two patches below; ticket #56 wires it into the shell unit |
| Quickshell patches | `modules/pkgs/quickshell/*.patch` | `load_qtquick_611.patch` (Omarchy's `OmarchyLoadPatch` and Qt 6.11 load interception) and `intercept-rescan-fix.patch` (removes a synchronous `scanDir()` that deadlocks plugin reload) |
| Supervisor and PATH | `modules/quickshell.nix`, `config/quickshell/scripts/` | systemd unit, monitor readiness, `qs-restart`, and the binaries on the unit PATH |
| User config | `config/omarchy/shell.json` | Our config, symlinked to `~/.config/omarchy/shell.json`; the vendored copy is the fallback |
| Helper gaps | `docs/known-broken-helpers.md` | Open, adapted, and not-needed helper work |

Do not edit a vendored file in place without recording it. If a local patch to
the vendored tree becomes necessary:

1. Add it under `vendor/omarchy/patches/NNN-short-name.patch`.
2. List it in the table above with the reason and the commit that introduced it.
3. Apply it after every sync, before rebuilding or restarting the shell.

Keep an upstream copy and a local edit in separate commits so the next sync can
tell them apart.

## Sync procedure

Use a clean worktree on the integration branch. Do not run a live switch while
syncing.

1. Choose a new upstream commit on `quattro`. Read its shell/theme migration
   notes before copying; QML and `shell.toml` templates change together.
2. Fetch and check out that commit in a temporary checkout:

   ```bash
   tmp="$(mktemp -d)"
   git clone https://github.com/omacom/omarchy "$tmp/omarchy"
   git -C "$tmp/omarchy" checkout <new-commit>
   ```

3. Review what changed before overwriting anything:

   ```bash
   for path in shell themes/tokyo-night config/omarchy default bin; do
     diff -ruN "vendor/omarchy/$path" "$tmp/omarchy/$path" || true
   done | less
   ```

4. Copy the five directories and the two upstream metadata files. `rsync
   --delete` makes the vendored tree exactly match the new pin; local patches
   under `vendor/omarchy/patches/` are not touched by this command:

   ```bash
   for path in shell themes/tokyo-night config/omarchy default bin; do
     rsync -a --delete "$tmp/omarchy/$path/" "vendor/omarchy/$path/"
   done
   cp "$tmp/omarchy/LICENSE" "$tmp/omarchy/version" vendor/omarchy/
   ```

5. Reapply any local patches from `vendor/omarchy/patches/` in numeric order.
   Resolve conflicts by updating the patch, not by editing vendored files
   silently.
6. Update the pin table, the version, and the captured date in this README.
   Include the upstream commit and the reason for the sync in the commit
   message.
7. Check the tree and run the build:

   ```bash
   git diff --check
   nix build --no-link \
     '.#nixosConfigurations.pc.config.home-manager.users.shahid.home.activationPackage'
   ```

   Build only the package closure here. A live `nixos-rebuild switch` is a
   separate, deliberate step.
8. Restart the shell and run the live verification below. Fix or record every
   failure in `docs/known-broken-helpers.md` before declaring the sync done.

## Rebuilding the patched Quickshell

The shell requires the patched Quickshell, not nixpkgs' stock version. The
package is defined in `modules/pkgs/quickshell.nix`, at Quickshell revision
`2b4501a282689792b62e94f3fb30d8f512324fe6`, with `--fuzz=0` patches.

Build only that package (run from the repository root):

```bash
nix build --no-link --print-out-paths --impure --expr '
  let
    flake = builtins.getFlake (toString ./.);
    pkgs = import flake.inputs.nixpkgs { system = "x86_64-linux"; };
  in pkgs.callPackage ./modules/pkgs/quickshell.nix { }
'
```

After ticket #56 wires the package into `modules/quickshell.nix`, the home
closure is the end-to-end check:

```bash
nix build --no-link \
  '.#nixosConfigurations.pc.config.home-manager.users.shahid.home.activationPackage'
```

Then apply it deliberately (not during a sync review):

```bash
nixos-rebuild switch --flake .#pc
```

Confirm the running binary after the switch:

```bash
quickshell --version
```

QML, theme, config, or helper changes do not require a Quickshell rebuild;
restarting the shell is enough. A change to the Quickshell source revision or
either patch does.

## Live verification

Set the path the shell and helpers use:

```bash
export OMARCHY_PATH="$HOME/dotfiles/vendor/omarchy"
```

1. The supervisor owns the process:

   ```bash
   qs-restart
   systemctl --user is-active quickshell
   journalctl --user -u quickshell -b --no-pager | tail -n 100
   ```

   `qs-restart` is the lock-aware path; it must wait for IPC readiness. There
   must be no QML import errors, no bindings that fail to resolve, and no
   crash loop in the journal.

2. IPC readiness returns Omarchy's value, not `pong`:

   ```bash
   quickshell ipc -p "$OMARCHY_PATH/shell" call shell ping
   # prints: ok
   ```

3. Theme state points at the vendored Tokyo Night theme:

   ```bash
   readlink -f "$HOME/.local/state/omarchy/current/theme"
   # -> $HOME/dotfiles/vendor/omarchy/themes/tokyo-night
   test -f "$HOME/.local/state/omarchy/current/theme/shell.toml"
   ```

   `shell.toml` is generated by Omarchy's `omarchy-theme-set` from
   `default/themed/shell.toml.tpl`; it is not part of the tokyo-night snapshot.

4. Own exactly one notification service and one polkit agent:

   ```bash
   busctl --user status org.freedesktop.Notifications
   busctl --user list | grep -i polkit
   pgrep -af 'swaync|dunst|notification-daemon'
   ```

   The notification bus name must belong to the Quickshell process, and there
   must be no second notification daemon. Trigger one `pkexec` action and
   confirm the Omarchy polkit dialog appears.

5. Exercise every surface in the default bar and the panels behind them:
   menu, workspaces, indicators, clock, elsewhen, weather, system update, tray,
   keyboard layout, agents, bluetooth, network, audio, monitor, power,
   clipboard, image picker, emoji picker, reminders, OSD, dock, notifications,
   and polkit. Open and close each one; check the actions, not just the paint.

6. Compare the live desktop with the local reference pack using
   [`docs/visual-reference.md`](../../docs/visual-reference.md): bar geometry,
   fonts, icons, spacing, colours, hover/focus states, and each panel.

7. Smoke-test the helpers the surfaces call, for example `omarchy-menu`,
   `omarchy-audio-output-sink`, `omarchy-network-status`,
   `omarchy-bluetooth-power`, `omarchy-battery-status`,
   `omarchy-powerprofiles-list`, `omarchy-monitor-state`, and
   `omarchy-theme-bg-set`. Record any failure in
   [`docs/known-broken-helpers.md`](../../docs/known-broken-helpers.md).

Visual parity is not "it launched". A sync is done only when the live checks
pass and the known-broken list matches what you actually saw.
