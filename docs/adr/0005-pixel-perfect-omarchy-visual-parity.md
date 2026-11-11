> **Status: superseded by ADR-0006.** Visual parity now comes from the fork, not independent reimplementation.

# Pixel-perfect Omarchy visual parity, with our own code

We keep the independent shell, but Omarchy's UI becomes a hard visual
acceptance target, not merely an inspiration. Every surface must match a
reference capture from the user's Omarchy machine in Tokyo Night at
3440x1440 / 1.33: geometry, spacing, typography, colour, icons, and
interaction states. The implementation stays our QML; Omarchy's theme files
and QML are read-only references for values and measurements, never copied.

## Consequences

- Work is split per surface, not per "theme pass"; each ticket carries its
  reference capture and measured values.
- A visual harness becomes the primary test seam. It captures our surface with
  grim, crops the measured region, and compares it with the reference.
- Visual parity is defined against a fixed resolution, scale, font set, and
  theme. Parity on other displays is not claimed.
- The earlier "Omarchy-shaped" UI is accepted as scaffolding only; it must be
  restyled or replaced surface by surface.
