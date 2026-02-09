# Kali Safe Updater

Self-resuming automated maintenance and upgrade script for **Kali Linux**.

Kali Safe Updater performs a **fully unattended system update** with automatic reboot handling, post-reboot resume via systemd, and safe shutdown after completion — designed for secure and reliable Linux workstation maintenance.

---

## Badges

![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Kali%20Linux-blue)
![Shell](https://img.shields.io/badge/language-Bash-informational)
![Release](https://img.shields.io/github/v/release/akshatcore/kali-safe-updater)

---

## Features

### Automated System Maintenance
- Repairs broken or interrupted packages  
- Performs full **non-interactive APT upgrade**  
- Cleans unused dependencies and cache  

### Hardware & Kernel Stability
- Synchronizes **kernel headers**  
- Rebuilds **all DKMS modules**  
- Handles GPU drivers:
  - NVIDIA  
  - AMD  
  - Intel  

### Complete Application Updates
- Updates **APT packages**
- Updates **Flatpak apps**
- Updates **Snap packages**

### Safety & Reliability
- Optional **Timeshift backup** before upgrade  
- Detects **reboot requirement automatically**  
- Creates **systemd resume service** after reboot  
- Continues update **without user login**  
- Waits for package operations to finish safely  
- Optional **automatic shutdown** after completion  
- Full **timestamped logging** in user home directory  

---

## Requirements

- Kali Linux (rolling)
- sudo privileges
- systemd
- Optional: Timeshift for backup support

---

## Installation

Clone the repository:

```bash
git clone https://github.com/akshatcore/kali-safe-updater.git
cd kali-safe-updater
chmod +x kali-safe-updater.sh
