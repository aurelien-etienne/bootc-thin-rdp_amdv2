# bootc-alma

An [AlmaLinux 10](https://almalinux.org/) bootc-based OS image for RDP thin clients. Built as an OCI container, deployed atomically via bootc.

## What it does

- **KDE Plasma** desktop with a minimal custom panel layout
- **KRDC** auto-launches on login and connects to the configured RDP server
- **WireGuard** VPN auto-connects on boot (split-tunnel)
- **LUKS2** full disk encryption with optional TPM2 enrollment
- **First-boot provisioning**: interactive setup (user account, LUKS passphrase, WireGuard key generation and VPN address)
- **Firewall**: default-drop on all interfaces; wg0 placed in the trusted zone
- Belgian French locale (`fr_BE.UTF-8`, `be-latin1` keyboard)
- Automatic bootc update checks

## Repository structure

```
files/
  scripts/          # Build-time scripts, run in order during image build
    10-base.sh        # Package install and removal
    11-disable-services.sh  # Service masking (cups, avahi, ModemManager, TTYs 2-6, ...)
    12-firewall.sh    # firewalld default-drop zone, enabled at boot
    20-provisioning.sh  # WireGuard file permissions, enable first-boot service
    50-branding.sh    # KDE theme setup
    89-initramfs.sh   # Dracut rebuild for TPM2
  system/           # Files copied verbatim into the image filesystem
    etc/wireguard/wg0.conf        # WireGuard template (server values from CI secrets)
    etc/polkit-1/rules.d/         # NM polkit rules: wg0 locked, WiFi free
    etc/skel/.config/             # KDE user defaults (power, screen lock, KRDC, KWallet)
    etc/systemd/system/           # first-boot-provision service + bootc update override
    usr/libexec/first-boot-provision.sh  # Interactive first-boot provisioning script
    usr/share/plasma/look-and-feel/be.okko.minimalpanel/  # Custom KDE panel layout
Dockerfile          # Container image definition
iso.toml            # bootc-image-builder ISO config (Anaconda, LUKS, locale)
Makefile            # Local build and testing targets
```

## CI/CD

GitHub Actions builds and pushes the container image to GHCR on every push to `main`. The ISO is built manually via the `build-iso` workflow.

### Required secrets

| Secret | Description |
|--------|-------------|
| `SIGNING_SECRET` | Cosign private key for image signing |
| `WG_PUBLIC_KEY` | WireGuard server public key |
| `LUKS_PLACEHOLDER_PASS` | LUKS passphrase used by the Anaconda installer during ISO install |

## Local development

The `image` target substitutes CI secrets with local test values before building and reverts them afterwards. Edit the values at the top of the `image` target in the Makefile to match your test environment.

```sh
make image        # Build the container image (requires sudo + podman)
make iso          # Build a bootable ISO via bootc-image-builder
make qcow2        # Build a QCOW2 disk image
make run-qemu-iso # Boot the ISO in QEMU for testing (creates a virtual disk)
make run-qemu     # Boot the installed disk image in QEMU
make vm           # Deploy ISO to a libvirt VM
make vm-tpm       # Same with TPM2 (Secure Boot in setup mode)
make vm-tpm-sb    # Same with TPM2 and Secure Boot enforced
make clean        # Remove ./output
```