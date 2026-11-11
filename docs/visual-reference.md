# Visual reference protocol

The reference UI is the Omarchy desktop on the other machine. Every visual
ticket compares one of our surfaces with one capture from this pack.

## Fixed conditions

- Theme: Tokyo Night.
- Resolution: 3440x1440 physical pixels.
- Scale: 1.33.
- Bar: top, default Omarchy layout from `config/quickshell/user/shell.json`.
- Same fonts installed on both machines; the shell uses the fontconfig
  `monospace` alias.
- Hide unrelated windows before capturing.

## Where captures live

Store them outside git, by default in `/tmp/omarchy-reference/`. The harness
reads `REFERENCE_DIR` and fails closed when a file is missing.

## Capture commands

On the Omarchy machine:

```bash
mkdir -p /tmp/omarchy-reference
grim /tmp/omarchy-reference/full-desktop.png
grim -g "0,0 3440x26" /tmp/omarchy-reference/bar.png
```

For each surface, open it, wait for the animation to settle, then capture the
full screen and crop the surface region:

```bash
grim /tmp/omarchy-reference/audio-panel.png
grim /tmp/omarchy-reference/network-panel.png
grim /tmp/omarchy-reference/bluetooth-panel.png
grim /tmp/omarchy-reference/power-panel.png
grim /tmp/omarchy-reference/monitor-panel.png
grim /tmp/omarchy-reference/weather-panel.png
grim /tmp/omarchy-reference/calendar.png
grim /tmp/omarchy-reference/notifications.png
grim /tmp/omarchy-reference/osd.png
grim /tmp/omarchy-reference/dock.png
grim /tmp/omarchy-reference/clipboard.png
grim /tmp/omarchy-reference/emoji.png
grim /tmp/omarchy-reference/image-picker.png
grim /tmp/omarchy-reference/reminders.png
grim /tmp/omarchy-reference/polkit.png
grim /tmp/omarchy-reference/wallpaper-picker.png
grim /tmp/omarchy-reference/menu.png
```

Capture interactive states too when the surface has them: hover, keyboard
focus, selected, empty, loading, error, and do-not-disturb where relevant. Name
them `<surface>-<state>.png`.

## Our captures

The harness captures our screen with `grim` and a region, then compares it with
the reference. The initial implementation lives in the visual-foundation
ticket. It records a side-by-side image for every failure.

## Fonts and icons

Reference captures only compare when both machines render the same font
family, weight, size, and icon set. Record the exact font package and icon
theme in the ticket if a surface depends on them.
