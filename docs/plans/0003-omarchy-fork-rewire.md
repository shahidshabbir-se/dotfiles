# Omarchy fork + NixOS rewiring — plan

Status: in progress. Supersedes spec #28 and the independent pixel-perfect
plan.

Related: [ADR 0006](../adr/0006-fork-omarchy-shell.md),
[spec 0003](../specs/0003-omarchy-fork-rewire.md),
[visual reference](../visual-reference.md),
[vendored shell sync](../../config/quickshell/README.md),
[known broken helpers](../known-broken-helpers.md).

## Repository layout

- Shipped shell: `config/quickshell/shell`, with `OMARCHY_PATH` at
  `config/quickshell`. The supervisor starts it with
  `quickshell -p "$OMARCHY_PATH/shell" -n`.
- User config: `config/quickshell/user/shell.json`, symlinked to
  `~/.config/omarchy/shell.json`.
- Supervisor: `config/quickshell/scripts/` and `modules/quickshell.nix`
  (rewired by ticket #56).
- Legacy independent shell: `legacy/independent-shell/`. Its QML, config, and
  QML tests are archived; it is not shipped.
- Tests: supervisor and ownership tests stay in `config/quickshell/tests/`;
  legacy plugin tests stay there and point at `legacy/independent-shell/`.
  The archived live notification harness lives in
  `legacy/independent-shell/tests/` so it cannot be mistaken for the shipped
  Omarchy ownership test.
- Helper status and upstream sync: `docs/known-broken-helpers.md` and
  `config/quickshell/README.md`.

## Target

- Vendored Omarchy shell QML/themes/helpers at a pinned commit.
- Patched Quickshell 0.3.2.r7 + OmarchyLoadPatch.
- Our systemd supervisor, monitor readiness, `qs-restart`, and config ownership.
- Tokyo Night theme state; Hypridle and Qylock remain.
- Arch-specific helpers adapted to NixOS.

## Ticket graph

| # | Ticket | Blocked by |
|---|---|---|
| F1 | Vendor Omarchy tree, license, and patched Quickshell package | None |
| F2 | Rewire supervisor, launch, config, and IPC readiness | F1 |
| F3 | Tokyo Night theme state; disable Omarchy idle/lock | F2 |
| F4 | Adapt helpers for menu, audio, network, bluetooth, power | F2 |
| F5 | Notification/polkit ownership; remove duplicate services | F2 |
| F6 | Live UI vs reference pack; fix broken helpers | F3, F4, F5 |
| F7 | Upstream sync procedure, license docs, legacy QML cleanup | F1 |
| F8 | Final PR verification and handback | F6, F7 |

## Notes

- F1 is the largest and riskiest: patched Quickshell build and vendored tree.
- F2 makes the real Omarchy UI appear under our supervisor; this is the first demoable milestone.
- F3-F5 can run in parallel after F2.
- F6 uses `/home/shahid/Pictures/omarchy-reference/`.
