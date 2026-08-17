# Omarchy network panel (reference)

Source: [basecamp/omarchy#6231](https://github.com/basecamp/omarchy/pull/6231) branch `quattro`.

**Not wired into our shell.** Read-only dump so you can mine logic / UI before writing a real `qs.features.network`.

## Layout

```
panel/          omarchy.network bar-widget (main Wi-Fi menu)
wifiqr/         omarchy.wifiqr panel (QR share)
speedtest/      speedtest panel opened from network
scripts/        omarchy-network-* helpers the panel shells out to
Ui/             qs.Ui deps Panel.qml imports
Commons/        qs.Commons (Style, Color, Util, Border)
```

## Hard deps (won't drop in as-is)

| Need | Notes |
|------|--------|
| `qs.Ui` / `qs.Commons` | Omarchy design system — not our `qs.shared.theme` |
| Plugin host | Omarchy loads via `manifest.json` + `PluginRegistry` |
| `Quickshell.Networking` | NM backend used for scan/connect/forget |
| PATH scripts | `omarchy-network-status`, `-band`, `-password`, `-qr`, `-speedtest`, `omarchy-dns`, `omarchy-launch-floating-terminal-with-presentation`, `omarchy-restart-wifi` |
| `wl-copy`, `nmcli`/`NetworkManager`, `iw`, `ip` | Script + panel side tools |

## Useful bits to steal

- `panel/Model.js` — pure parse/format (status tabs, band, SSID decode, credential rules)
- `scripts/omarchy-network-status` / `-band` — CLI contracts the QML polls
- Connect / passphrase / forget flow in `panel/Panel.qml` (search `openPasswordPrompt`, `activateNetwork`)

## Do not

- Import this tree from `composition/` or `features/`
- Copy `Ui/*` wholesale into `shared/` — reimplement against our theme when integrating
