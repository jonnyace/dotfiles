# Pacman Hooks

This directory contains pacman hooks for Arch Linux system maintenance.

## Installation

```bash
sudo cp *.hook /etc/pacman.d/hooks/
```

## Hooks

### 99-sbctl.hook

Automatically signs EFI binaries with sbctl after kernel or bootloader updates to maintain Secure Boot functionality.

**Triggers on:**
- Linux kernel updates (linux, linux-lts, linux-zen, linux-hardened)
- Limine bootloader updates
- systemd updates (systemd-stub)

**Action:**
Runs `sbctl sign-all` to re-sign all enrolled EFI binaries.

**First-time setup:**
```bash
# Sign all EFI binaries
sudo sbctl verify
sudo sbctl sign-all

# Install the hook
sudo cp 99-sbctl.hook /etc/pacman.d/hooks/
```
