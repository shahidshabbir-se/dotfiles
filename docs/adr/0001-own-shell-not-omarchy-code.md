> **Status: superseded by ADR-0006.** The management model survives; the shell now vendors Omarchy QML.

# Build our own shell; borrow only Omarchy's management model

We want the way Omarchy manages its Quickshell desktop — one long-lived
process, declarative layout, supervised lifecycle, IPC — without depending on
Omarchy's tree, its Arch-oriented helper commands, or its patched Quickshell.
So the shell is our own QML under `config/quickshell`, built from plugins we
own, and only the *management model* is borrowed. Vendoring upstream Omarchy
and consuming a third-party NixOS port were both rejected: the first was
already explored and dropped, and the second would make the desktop's behavior
depend on someone else's fork and release cadence.

## Considered Options

- **Vendor upstream Omarchy and package it ourselves** — real desktop parity,
  but ~60 Arch-oriented helper commands, a patched Quickshell snapshot, and
  every upstream release becomes our sync work.
- **Consume `zicochaos/omarchy-nix` or `nixarchy`** — fastest path to the real
  shell, but their module is all-or-nothing (Hyprland session, apps, SDDM) and
  the desktop would track someone else's fork.

## Consequences

- We own every QML file, every helper script, and every bug.
- There is no runtime plugin loading and no third-party plugin marketplace;
  plugins are built into the shell.
- The deleted `config/quickshell` tree from commit `7f606dd^` is reference
  material only; it is not restored. The new shell is built in Omarchy's
  shape, not from the old composition.
