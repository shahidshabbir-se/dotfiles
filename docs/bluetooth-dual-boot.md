# Bluetooth dual boot: NixOS + Windows

Use this after reinstalling NixOS or replacing a Bluetooth device. It keeps the
same device bond usable in both operating systems without repeatedly forgetting
and pairing devices.

## Important rules

- Pair the device in **Linux first**, then pair it in **Windows**.
- Use Windows as a **read-only source** for the final pairing key. Do not edit
  the offline Windows `SYSTEM` hive.
- Keep pairing keys private. Never commit them or paste them into chat.
- Do not pair or forget a working device after synchronising its key; doing so
  creates a new bond and requires syncing again.

## One-time setup

1. Pair and trust each device in Linux.
2. Boot Windows and pair the same device there.
3. Fully shut down Windows so its registry is safe to read:
   ```cmd
   shutdown /s /t 0
   ```
   Disable Fast Startup permanently if possible.
4. Back in Linux, verify the Windows system partition with `lsblk`. On this
   machine it is `/dev/nvme0n1p3`. Mount it read-only:
   ```sh
   sudo mkdir -p /mnt/windows
   sudo mount -o ro -t ntfs-3g /dev/nvme0n1p3 /mnt/windows
   ```
5. Open the offline Windows registry:
   ```sh
   nix-shell -p chntpw --run 'chntpw -e /mnt/windows/Windows/System32/config/SYSTEM'
   ```
6. In `chntpw`, resolve the active control set:
   ```text
   cd \Select
   cat Current
   ```
   If it prints `1`, use `ControlSet001`; if it prints `2`, use
   `ControlSet002`.
7. Navigate to the Bluetooth adapter key. `chntpw` is case-sensitive, so use
   the lowercase names shown by `ls`:
   ```text
   cd \ControlSet001\Services\BTHPORT\Parameters\Keys
   ls
   cd <adapter-mac-without-colons>
   ls
   hex <device-mac-without-colons>
   ```
   A classic Bluetooth device has a direct 16-byte `REG_BINARY` value. The
   `:00000` prefix in the hexdump is an offset, **not** part of the key.
8. Stop BlueZ and update only the Linux device's `[LinkKey] Key=` value. Join
   the 16 Windows bytes in their displayed order, uppercase, without spaces or
   the `00000` offset. The result must be exactly 32 hexadecimal characters.
   Keep the existing `Type=` and `PINLength=` values unchanged.
   ```sh
   sudo systemctl stop bluetooth
   sudoedit /var/lib/bluetooth/<adapter-MAC>/<device-MAC>/info
   sudo systemctl start bluetooth
   ```
9. Unmount Windows:
   ```sh
   sudo umount /mnt/windows
   ```

If `chntpw` shows a device subkey containing fields such as `LTK` or `IRK`, it
is a Bluetooth LE device and needs an LE-specific key mapping; do not replace
only `[LinkKey]`.

## Automatic reconnect on NixOS

`Trusted=true` permits a device but does not make BlueZ initiate a connection
after boot or a Bluetooth-service restart. This configuration declares a
`bluetooth-auto-connect` service that, after BlueZ starts, retries all trusted
devices for 30 seconds. It discovers devices dynamically; no device MACs are
hard-coded.

Apply the NixOS configuration after a reinstall or change:

```sh
sudo nixos-rebuild switch --flake ~/dotfiles#pc
```

Check the reconnect service if devices do not reconnect:

```sh
systemctl status bluetooth-auto-connect.service
```

The devices must be powered on, in range, and not actively connected to a
different host.

Bluetooth hardware-volume sync is disabled so PipeWire restores the previous
local volume after reconnect instead of accepting a headset's maximum volume.
Headset volume buttons therefore do not control the system volume.

## Troubleshooting

- `br-connection-key-missing`: the Linux key is stale, malformed, or belongs
  to a different pairing. Pair the device in Windows again, fully shut down,
  and repeat the Windows-to-Linux key sync.
- A `Key=` length other than 32 means the key was copied incorrectly. Commonly,
  the five `00000` offset characters from `chntpw` were included by mistake.
- If Windows cannot be mounted read-only, make sure BitLocker is unlocked and
  Windows was fully shut down rather than hibernated.
