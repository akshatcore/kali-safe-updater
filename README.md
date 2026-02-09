# Kali Safe Updater

Self-resuming automated maintenance and upgrade script for **Kali Linux**.

This tool performs a **complete unattended system update** with:

- Broken package repair
- Full APT upgrade (non-interactive)
- Kernel header synchronization
- DKMS rebuild for all kernel modules
- GPU driver handling (NVIDIA / AMD / Intel)
- Flatpak and Snap updates
- Optional Timeshift backup
- Automatic reboot detection and resume via systemd
- Safe shutdown after completion
- Full logging in user home directory

---

## Features

### Automated Maintenance
- Repairs interrupted package states
- Updates entire system stack
- Cleans unused dependencies

### Hardware Stability
- Ensures matching kernel headers
- Rebuilds DKMS modules
- Installs correct GPU drivers

### Enterprise-Style Orchestration
- Detects reboot requirement
- Creates systemd resume service
- Continues update **without user login**
- Performs final shutdown automatically

---

## Requirements

- Kali Linux (rolling)
- sudo privileges
- systemd
- optional: Timeshift for backups

---

## Installation

Clone the repository:

```bash
git clone https://github.com/akshatcore/kali-safe-updater.git
cd kali-safe-updater
chmod +x kali-safe-updater.sh
# kali-safe-updater
# kali-safe-updater
