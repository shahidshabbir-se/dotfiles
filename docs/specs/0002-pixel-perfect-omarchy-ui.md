## Problem Statement

The independent shell currently matches Omarchy's *management model* but not
its UI. It runs a 36px flat bar, uses SF Pro Display, hardcodes a Tokyo Night
palette, and shows only a clock, a notification bell, a calendar, and a basic
notification center. Omarchy on my other machine has a 26px themed bar, a
monospace shell font, six populated sections, designed widgets, and full
panels and overlays. It looks like a different desktop.

I want the independent shell's UI to be pixel-perfect against my Omarchy
reference while keeping the code independent. I am willing to go slowly and
build each surface properly. I do not want an "inspired by Omarchy" look, and I
do not want to copy or vendor Omarchy's QML.

## Solution

Treat the Omarchy desktop on my other machine as a read-only visual reference.
Capture that desktop surface by surface at 3440x1440 and 1.33 scale in Tokyo
Night. Extract the measured design tokens and geometry from those captures and
from Omarchy's theme values. Rebuild our QML, one surface at a time, until each
surface matches its reference inside a screenshot-diff harness. Keep our
systemd supervisor, shell config ownership, static registry, and IPC surface.

The visual harness becomes the primary test seam: capture our surface with
grim, crop the measured region, compare it with the reference, and record the
diff next to the behaviour checks.

## User Stories

1. As a desktop user, I want the reference desktop captured at the same resolution and scale as mine, so visual comparisons are meaningful.
2. As a desktop user, I want a documented capture protocol, so every reference image is produced the same way.
3. As a desktop user, I want a visual harness that captures our surface and compares it to the reference, so "looks right" becomes measurable.
4. As a desktop user, I want the harness to fail when a reference capture is missing, so no visual ticket is silently marked done.
5. As a desktop user, I want the shell's colour, spacing, radius, and type values to come from named tokens, so parity changes happen in one place.
6. As a desktop user, I want the Tokyo Night colours to match the reference exactly, so the bar and panels read the same.
7. As a desktop user, I want the shell font to match the reference monospace alias, so text metrics match.
8. As a desktop user, I want the bar to be 26px high at the reference font base, so the bar geometry matches.
9. As a desktop user, I want the six bar sections and their gaps to match the reference, so widget placement matches.
10. As a desktop user, I want the bar background, border, and corner treatment to match, so the chrome matches.
11. As a desktop user, I want hover, focus, and selected states to match, so interactions feel the same.
12. As a desktop user, I want the menu widget and menu surface to match, so the launcher looks like the reference.
13. As a desktop user, I want the workspaces widget to match, including active and occupied states.
14. As a desktop user, I want the indicators widget to match its grouping, spacing, and icons.
15. As a desktop user, I want the clock widget and calendar popup to match geometry, type, and highlight states.
16. As a desktop user, I want the Elsewhen widget to match, including configured time zones.
17. As a desktop user, I want the weather widget and panel to match, including loading and unavailable states.
18. As a desktop user, I want the system-update widget to match, including its attention state.
19. As a desktop user, I want the tray widget to match, including icons and drawer behaviour.
20. As a desktop user, I want the keyboard-layout widget to match, including layout labels.
21. As a desktop user, I want the agents widget to match, including its usage readout.
22. As a desktop user, I want the Bluetooth widget and panel to match, including device rows and states.
23. As a desktop user, I want the network widget and panel to match, including Wi-Fi rows and signal states.
24. As a desktop user, I want the audio widget and panel to match, including sliders and device rows.
25. As a desktop user, I want the monitor widget and panel to match, including resolution and scale readouts.
26. As a desktop user, I want the power widget and panel to match, including action rows and confirmation states.
27. As a desktop user, I want the media widget to match, including artwork, progress, and controls.
28. As a desktop user, I want notification toasts and the notification center to match, including empty, unread, and DND states.
29. As a desktop user, I want the OSD to match, including volume and brightness variants.
30. As a desktop user, I want the dock to match, including pinned and running states.
31. As a desktop user, I want the clipboard panel to match, including text and image rows.
32. As a desktop user, I want the emoji picker and image picker to match, including grid and selection states.
33. As a desktop user, I want the reminders panel to match, including empty and populated states.
34. As a desktop user, I want the polkit dialog to match, including password, error, and button states.
35. As a desktop user, I want the wallpaper picker and applied wallpaper to match, including preview and selection states.
36. As a desktop user, I want transitions and animation durations to match where the reference animates, so motion feels the same.
37. As a desktop user, I want the full desktop compared at the end, so the surfaces compose correctly.
38. As a developer, I want each visual ticket to carry its reference capture, measured geometry, tokens, and diff command, so it can be implemented without guessing.
39. As a developer, I want reference captures stored outside the repo, so large images do not bloat git.
40. As a developer, I want a side-by-side image for every failed diff, so I can see what changed.
41. As a developer, I want the harness to crop by measured regions, so an unrelated window does not fail a surface check.
42. As a developer, I want static surfaces held to strict geometry and colour thresholds, so drift is caught.
43. As a developer, I want text and antialiasing differences handled by a defined tolerance, so font rasterisation does not create false failures.
44. As a developer, I want the existing IPC and systemd tests to keep passing, so visual work never breaks behaviour.
45. As a developer, I want no Omarchy QML imported or copied, so the implementation stays independent.
46. As a developer, I want the reference theme files read only for values, so theme updates can be re-measured deliberately.
47. As a developer, I want the visual tickets ordered by foundation, bar, widgets, overlays, and final audit, so each step is verifiable.
48. As a developer, I want a missing reference capture to block final acceptance, so "pixel-perfect" cannot be claimed without evidence.

## Implementation Decisions

- **Reference protocol.** The reference UI is the user's Omarchy machine at 3440x1440, 1.33 scale, Tokyo Night, default bar layout. Capture with grim after hiding unrelated windows. Capture one full desktop and one image per surface. Store under `REFERENCE_DIR` (default `/tmp/omarchy-reference`), outside git.
- **Read-only reference.** Omarchy's `shell/` QML and `themes/tokyo-night` files may be read to extract values and measurements. No file is copied into this repo, and no Omarchy import or helper command is used by our shell.
- **Design tokens.** Colour, spacing, radius, bar size, font family, and type scale become named tokens in the shared `Color`/`Style` modules. Values come from the reference captures and the Tokyo Night theme values. No hardcoded palette inside widgets.
- **Typography.** The shell uses the same fontconfig monospace alias as the reference, with the same base size and derived scale. SF Pro Display is removed from shell UI.
- **Bar geometry.** The bar is 26px high at the reference base size, with the reference's section gaps, padding, background, border, and corner treatment. The six sections keep the existing ordered model.
- **Surface-by-surface rebuild.** Each widget, panel, overlay, and dialog is its own ticket with a reference capture, measured values, and a visual diff. Do not restyle unrelated surfaces in the same ticket.
- **Visual harness.** One script captures a named surface, crops the measured region, compares it with the reference, writes a side-by-side diff, and exits non-zero above the threshold. It supports a missing-reference mode that fails with a clear message.
- **Thresholds.** Geometry and colour are exact or near-exact; text rasterisation is allowed a defined perceptual tolerance. Each ticket states its threshold. The final full-desktop audit requires every surface to pass and the composed desktop to pass its own diff.
- **Behaviour is preserved.** The existing systemd supervisor, `shell.json`, static registry, IPC targets, notification ownership, QS restart semantics, and current behaviour tests remain. Visual work must not regress them.
- **Reference pack is required.** A visual ticket is not complete until its reference capture exists and the diff is recorded. If the user has not supplied a capture, the ticket reports blocked rather than inventing a target.
- **Ordering.** Foundation (harness, tokens, bar shell) comes first. Widgets depend on the bar shell. Panels and overlays depend on the bar/registry. Animations and the full audit come after the surfaces they cover.

## Testing Decisions

- The primary seam is the visual harness at the session boundary: capture our real surface with grim, crop it, compare with the reference, and keep the evidence. This tests what the user sees, not QML structure.
- Each visual ticket must record: reference path, capture command, crop region, measured geometry/colour values, diff metric, threshold, and a side-by-side artifact.
- Static surfaces require exact geometry and colour within the ticket's tolerance. Text-heavy surfaces use a perceptual diff plus human side-by-side review, because font rasterisation differs across machines.
- Behaviour tests from the existing harness remain: systemd state, IPC ping, shell config reload, notification ownership/DND, calendar state, remote session, polkit registration, and restart semantics.
- A visual ticket with no reference capture fails closed. It may implement the surface from measured tokens, but it cannot claim completion without the reference diff.
- The final pixel audit captures the full desktop with the same layout and wallpaper and runs both per-surface and full-frame comparisons.

## Out of Scope

- Copying, vendoring, or importing Omarchy's QML, helper commands, or patched Quickshell.
- App retinting, theme templates for GTK/terminals/browsers, or Omarchy's theme marketplace.
- Visual parity on resolutions, scales, or font sets other than the fixed reference.
- Restyling Qylock or Hypridle; they remain separate and keep their current UI.
- Behaviour that has not yet been implemented; visual tickets build on the existing independent plugins and IPC surface.

## Further Notes

- This spec supersedes the visual assumptions of the earlier shell spec. The supervisor, config, registry, notifications, calendar, remote-session, and polkit behaviour remain useful foundations.
- Reference captures are the first blocker. The capture protocol and filenames are documented in the visual-reference guide.
- The work is intentionally slow: one surface, one reference, one diff, then the next.
