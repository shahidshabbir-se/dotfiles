# Bluetooth Dual Boot (NixOS + Windows)

## System

- **Host:** pc (desktop)
- **NixOS flake:** `<dotfiles_path>` (`. #pc`)
- **Bluetooth adapter:** `<adapter_mac>`
- **Windows partition:** `/dev/<windows_partition>` (NTFS)
- **EFI:** `/boot` (shared, GRUB manages boot)

## Working method

The reliable approach: **pair on Linux → copy the key to Windows registry.**

### Step-by-step

1. **Remove device from both OSes** (forget in Bluetooth settings)
2. **Put device in pairing mode**
3. **Pair on Linux:**
   ```bash
   bluetoothctl --timeout 15 scan on
   bluetoothctl pair XX:XX:XX:XX:XX:XX
   bluetoothctl trust XX:XX:XX:XX:XX:XX
   bluetoothctl connect XX:XX:XX:XX:XX:XX
   ```
4. **Verify a `[LinkKey]` section exists** in the info file:
   ```bash
   sudo cat /var/lib/bluetooth/<adapter_mac>/<device_mac>/info
   ```
   Must have `[LinkKey]` with `Key=...`. If missing, the pairing didn't persist — try again.
5. **Copy Linux key to Windows registry:**
   ```bash
   sudo mkdir -p /mnt
   sudo mount -t ntfs-3g /dev/<windows_partition> /mnt
   ```
   Then get the key from Linux info file:
   ```bash
   sudo grep Key /var/lib/bluetooth/<adapter_mac>/<device_mac>/info
   ```
   Create a `.reg` file with the key (bytes as comma-separated hex, uppercase):
   ```
   Windows Registry Editor Version 5.00

   [HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BTHPORT\Parameters\Keys\<adapter_mac_no_colons>]
   "<device_mac_no_colons>"=hex:XX,XX,XX,XX,XX,XX,XX,XX,XX,XX,XX,XX,XX,XX,XX,XX
   ```
   Import it:
   ```bash
   nix-shell -p chntpw --run 'reged -I /mnt/Windows/System32/config/SYSTEM "HKEY_LOCAL_MACHINE\SYSTEM" /tmp/<name>.reg -C'
   ```
   Verify:
   ```bash
   nix-shell -p chntpw --run 'cd /mnt/Windows/System32/config && chntpw -e SYSTEM' <<'EOF'
   cd ControlSet001\Services\BTHPORT\Parameters\Keys\<adapter_mac_no_colons>
   cat <device_mac_no_colons>
   q
   EOF
   ```
   Clean up:
   ```bash
   sudo umount /mnt
   ```
6. **Reboot to Windows** — device should auto-connect. **Do NOT remove or re-pair.**

### Extracting key from Windows (reverse direction)

If you pair on Windows first and need the key for Linux:

```bash
sudo mount -t ntfs-3g /dev/<windows_partition> /mnt
nix-shell -p chntpw --run 'cd /mnt/Windows/System32/config && chntpw -e SYSTEM' <<'EOF'
cd ControlSet001\Services\BTHPORT\Parameters\Keys\<adapter_mac_no_colons>
cat <device_mac_no_colons>
q
EOF
sudo umount /mnt
```

Then write the hex value (continuous string, uppercase) into the `[LinkKey]` section of the Linux info file at `/var/lib/bluetooth/<adapter_mac>/<device_mac>/info`:

```
[LinkKey]
Key=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Type=4
PINLength=0
```

Then restart Bluetooth:
```bash
sudo systemctl restart bluetooth
```

## Auto-connect behavior

- Device may NOT auto-connect on Linux — some earbuds require manual connect each time
- Set `Trusted=true` in info file to help, but not guaranteed
- Windows usually auto-connects once the key matches

## Troubleshooting

### `br-connection-key-missing`

The key in Linux info file doesn't match what the device expects. The device was likely re-paired on the other OS. Re-sync the key (copy from the OS where it works).

### No `[LinkKey]` in info file after pairing

The pairing didn't persist. Remove the device (`bluetoothctl remove <mac>`), restart Bluetooth (`sudo systemctl restart bluetooth`), and pair again with device in pairing mode.

### Device shows "Paired: no" after "Pairing successful"

BlueZ shows pairing briefly but doesn't save the key. Try removing, restarting Bluetooth service, and re-pairing with the device in fresh pairing mode.

### Windows partition won't mount read-write

Disable Windows Fast Startup (Power Options → Choose what power buttons do → Turn on fast startup) or use a full shutdown (`shutdown /s /t 0` in Windows cmd).
