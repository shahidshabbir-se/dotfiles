# Fork Omarchy's shell instead of reimplementing its UI

We vendor Omarchy's `shell/` QML, Tokyo Night theme, config defaults, and
helper commands at a pinned upstream commit, build the patched Quickshell the
shell requires, and rewire the integration to our systemd supervisor, config
ownership, monitor readiness, and restart semantics. The independent-QML and
pixel-perfect-reimplementation decisions were rejected: they cannot deliver
the exact UI at acceptable cost. Omarchy is MIT-licensed, so the copy is legal
with the notice preserved.

## Consequences

- The shell becomes a deliberate fork; upstream updates are merged, not
  followed automatically.
- We own the NixOS adaptation of Arch-oriented helper commands.
- The independent shell QML becomes legacy; its supervisor, config, tests, and
  operational lessons remain.
- ADR 0001 (no Omarchy code), ADR 0003 (static registry), ADR 0004 (raw IPC),
  and ADR 0005 (independent pixel parity) are superseded for the shipped UI.
- ADR 0002 (systemd supervision) still applies.

## References

- [Vendored shell README](../../vendor/omarchy/README.md): pin, copied paths,
  local patches, and the exact upstream sync procedure.
- [Known broken helpers](../known-broken-helpers.md): the helper gaps and their
  status.
- [Legacy independent shell](../../legacy/independent-shell/README.md): what
  was archived and what remains.
