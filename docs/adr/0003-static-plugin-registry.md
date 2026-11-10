# A static plugin registry, not a manifest host

Every built-in plugin is registered in one `Registry.qml` keyed by id, instead
of scanning plugin directories and reading a `manifest.json`. Omarchy's
manifest host exists to support third-party plugins, and we explicitly allow
none; paying for discovery, schema validation, settings pages, and
enable/disable state would buy nothing. `shell.json` still refers to plugins by
id, so the layout stays Omarchy-shaped.

## Consequences

- Adding a plugin means a folder plus one registry entry.
- A wrong id fails at load instead of being skipped as an unknown manifest.
- There is no runtime discovery, no plugin settings schema, and no
  compatibility with Omarchy's plugin format.
