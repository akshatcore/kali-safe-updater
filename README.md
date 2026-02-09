# Kali Safe Updater

Self-resuming automated maintenance and upgrade script for **Kali Linux**.

Kali Safe Updater performs a **fully unattended system update** with automatic reboot handling, post-reboot resume via systemd, and safe shutdown after completion — designed for secure and reliable Linux workstation maintenance.

---

## Badges

![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Kali%20Linux-blue)
![Language](https://img.shields.io/badge/language-Bash-black)
![Release](https://img.shields.io/badge/release-v1.0.0-orange)
![Maintained](https://img.shields.io/badge/maintained-yes-brightgreen)
![Status](https://img.shields.io/badge/status-stable-success)

---

## Features

### Automated System Maintenance

- Repairs broken or interrupted packages  
- Performs full **non-interactive APT upgrade**  
- Ensures **kernel header synchronization**  
- Rebuilds **DKMS modules for all kernels**  
- Handles **GPU driver installation**
  - NVIDIA  
  - AMD  
  - Intel  
- Updates:
  - APT packages  
  - Flatpak applications  
  - Snap packages  

---

### Safety & Reliability

- Optional **Timeshift backup** before upgrade  
- Detects **reboot requirement automatically**  
- Creates **systemd resume service after reboot**  
- Continues update **without user login**  
- Waits for **package operations to finish safely**  
- Optional **automatic shutdown after completion**  
- Full **timestamped logging in user home directory**

---

## Requirements

- Kali Linux (rolling)  
- `sudo` privileges  
- `systemd`  
- Optional: **Timeshift** for backup support  

---

## Installation

Clone the repository:

```bash
git clone https://github.com/akshatcore/kali-safe-updater.git
cd kali-safe-updater
chmod +x kali-safe-updater.sh
```

---

## Usage

Run the updater with **root privileges**:

```bash
sudo ./kali-safe-updater.sh
```

> Root (`sudo`) access is required because the script performs  
> system upgrades, kernel module rebuilds, driver installation,  
> and system shutdown/reboot operations.

---

## Logging

Logs are automatically saved in:

```
~/kali_update_<date>_<time>.log
```

These logs include:

- Package repair output  
- Upgrade progress  
- DKMS rebuild status  
- Driver installation results  
- Reboot/shutdown actions  

---

## Release

**Current version:** `v1.0.0`

Includes:

- Full unattended upgrade workflow  
- DKMS rebuild automation  
- GPU driver handling  
- Reboot-resume orchestration  
- Safe shutdown logic  
- Structured logging  

---

## License

This project is licensed under the **MIT License**.  
See the `LICENSE` file for details.

---

## Author

**Akshat Tiwari**  
GitHub: https://github.com/akshatcore/kali-safe-updater 