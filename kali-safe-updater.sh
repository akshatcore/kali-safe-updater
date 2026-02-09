#!/bin/bash

set -euo pipefail

STATE_DIR="/var/lib/kali-safe-updater"
RESUME_FLAG="$STATE_DIR/resume"

REAL_USER="${SUDO_USER:-$USER}"
LOGFILE="/home/$REAL_USER/kali_update_$(date +%F_%H-%M-%S).log"

mkdir -p "$STATE_DIR"

echo "===== KALI SAFE UPDATE START =====" | tee -a "$LOGFILE"

error_exit() {
    echo "Error occurred. Check log: $LOGFILE"
    exit 1
}

trap error_exit ERR

# ---------------- RESUME MODE (AFTER REBOOT, NO LOGIN REQUIRED) ----------------

if [ -f "$RESUME_FLAG" ]; then
    echo "Resuming post-reboot maintenance in background..." | tee -a "$LOGFILE"
    rm -f "$RESUME_FLAG"
    RESUMED="yes"
else
    RESUMED="no"
fi

# ---------------- USER CHOICES FIRST (ONLY IF NOT RESUMED) ----------------

if [ "$RESUMED" = "no" ]; then
    echo "Select GPU configuration:"
    echo "1) NVIDIA"
    echo "2) AMD"
    echo "3) Intel"
    echo "4) Skip GPU setup"
    read -rp "Enter choice [1-4]: " GPU_CHOICE

    CREATE_BACKUP="n"
    if command -v timeshift >/dev/null 2>&1; then
        read -rp "Create Timeshift backup before update? (y/N): " CREATE_BACKUP
    fi

    SHUTDOWN_AFTER_UPDATE="n"
    read -rp "Shutdown system after update is finished? (y/N): " SHUTDOWN_AFTER_UPDATE

    echo "$GPU_CHOICE" > "$STATE_DIR/gpu_choice"
    echo "$CREATE_BACKUP" > "$STATE_DIR/backup_choice"
    echo "$SHUTDOWN_AFTER_UPDATE" > "$STATE_DIR/shutdown_choice"

    echo "User configuration captured. Proceeding with automated maintenance..." | tee -a "$LOGFILE"
else
    GPU_CHOICE="$(cat "$STATE_DIR/gpu_choice")"
    CREATE_BACKUP="$(cat "$STATE_DIR/backup_choice")"
    SHUTDOWN_AFTER_UPDATE="$(cat "$STATE_DIR/shutdown_choice")"
fi

# ---------------- OPTIONAL BACKUP ----------------

if [[ "$CREATE_BACKUP" =~ ^[Yy]$ ]]; then
    echo "Creating Timeshift snapshot..." | tee -a "$LOGFILE"
    sudo timeshift --create --comments "Pre-update snapshot" --tags D | tee -a "$LOGFILE"
fi

# ---------------- FIX BROKEN PACKAGES ----------------

echo "Checking and fixing broken packages..." | tee -a "$LOGFILE"
sudo dpkg --configure -a | tee -a "$LOGFILE"
sudo apt --fix-broken install -y | tee -a "$LOGFILE"

# ---------------- UPDATE REPOSITORIES ----------------

echo "Updating package lists..." | tee -a "$LOGFILE"
sudo apt update | tee -a "$LOGFILE"

# ---------------- FULL SYSTEM UPGRADE (NON-INTERACTIVE) ----------------

echo "Performing full system upgrade..." | tee -a "$LOGFILE"
sudo DEBIAN_FRONTEND=noninteractive \
     NEEDRESTART_MODE=a \
     apt full-upgrade -y | tee -a "$LOGFILE"

# ---------------- ENSURE KERNEL HEADERS ----------------

KERNEL="$(uname -r)"
echo "Ensuring kernel headers for $KERNEL ..." | tee -a "$LOGFILE"
sudo apt install -y "linux-headers-$KERNEL" | tee -a "$LOGFILE" || true

# ---------------- REBUILD ALL DKMS MODULES ----------------

if command -v dkms >/dev/null 2>&1; then
    echo "Rebuilding DKMS modules..." | tee -a "$LOGFILE"
    sudo dkms autoinstall | tee -a "$LOGFILE" || true

    echo "DKMS status:" | tee -a "$LOGFILE"
    dkms status | tee -a "$LOGFILE"

    if dkms status | grep -i "build error" >/dev/null 2>&1; then
        echo "Warning: Some DKMS modules failed to build. Review log." | tee -a "$LOGFILE"
    fi
fi

# ---------------- GPU DRIVER HANDLING ----------------

case "$GPU_CHOICE" in
    1)
        echo "Installing NVIDIA drivers..." | tee -a "$LOGFILE"
        sudo apt install -y nvidia-driver nvidia-dkms | tee -a "$LOGFILE" || true
        sudo dkms autoinstall | tee -a "$LOGFILE" || true
        ;;
    2)
        echo "Installing AMD graphics stack..." | tee -a "$LOGFILE"
        sudo apt install -y firmware-amd-graphics mesa-vulkan-drivers mesa-utils | tee -a "$LOGFILE" || true
        ;;
    3)
        echo "Installing Intel graphics stack..." | tee -a "$LOGFILE"
        sudo apt install -y intel-media-va-driver-non-free mesa-vulkan-drivers mesa-utils | tee -a "$LOGFILE" || true
        ;;
    4)
        echo "Skipping GPU driver setup." | tee -a "$LOGFILE"
        ;;
    *)
        echo "Invalid GPU choice. Skipping GPU setup." | tee -a "$LOGFILE"
        ;;
esac

# ---------------- UPDATE FLATPAK ----------------

if command -v flatpak >/dev/null 2>&1; then
    echo "Updating Flatpak applications..." | tee -a "$LOGFILE"
    flatpak update -y | tee -a "$LOGFILE"
fi

# ---------------- UPDATE SNAP ----------------

if command -v snap >/dev/null 2>&1; then
    echo "Updating Snap applications..." | tee -a "$LOGFILE"
    sudo snap refresh | tee -a "$LOGFILE"
fi

# ---------------- CLEANUP ----------------

echo "Cleaning unused packages..." | tee -a "$LOGFILE"
sudo apt autoremove -y | tee -a "$LOGFILE"
sudo apt autoclean | tee -a "$LOGFILE"

echo "===== UPDATE COMPLETE =====" | tee -a "$LOGFILE"

# ---------------- REBOOT HANDLING WITH AUTO-RESUME ----------------

if [ -f /var/run/reboot-required ] && [ "$RESUMED" = "no" ]; then
    echo "Reboot required. Preparing automatic resume..." | tee -a "$LOGFILE"

    touch "$RESUME_FLAG"

    SERVICE_FILE="/etc/systemd/system/kali-safe-updater-resume.service"

    sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Resume Kali Safe Updater After Reboot
After=network.target

[Service]
Type=oneshot
ExecStart=$(realpath "$0")
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reexec
    sudo systemctl enable kali-safe-updater-resume.service

    echo "Rebooting system to continue update..." | tee -a "$LOGFILE"
    sudo reboot
    exit 0
fi

# ---------------- WAIT FOR PACKAGE OPERATIONS BEFORE SHUTDOWN ----------------

echo "Ensuring no package operations are running before shutdown..." | tee -a "$LOGFILE"

while pgrep -x apt >/dev/null || pgrep -x dpkg >/dev/null; do
    echo "Waiting for package operations to finish..." | tee -a "$LOGFILE"
    sleep 5
done

# ---------------- OPTIONAL SHUTDOWN ----------------

if [[ "$SHUTDOWN_AFTER_UPDATE" =~ ^[Yy]$ ]]; then
    echo "Shutting down system as requested..." | tee -a "$LOGFILE"
    sudo shutdown now
fi

echo "Log saved at: $LOGFILE"

