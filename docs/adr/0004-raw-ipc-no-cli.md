> **Status: superseded by ADR-0006.** The fork uses Omarchy's IPC wrapper.

# Raw Quickshell IPC, with one restart script

Hyprland bindings call `quickshell ipc call <target> <method>` directly rather
than going through a custom `qsctl`. We still ship `qs-restart`, because the
systemd decision depends on a lock-aware restart that waits for the
notification bus name; that is lifecycle, not IPC.

## Consequences

- Bindings are longer and repeat the config path.
- There is no single place to add command aliases or argument validation.
- Restart semantics stay in one audited script rather than spread across
  bindings.
