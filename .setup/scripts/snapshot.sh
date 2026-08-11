#!/usr/bin/env bash

# Added by zb arch install script
# This script creates a snapshot of root

set -e

if [[ "$EUID" != 0 ]]; then
    echo 'Must run as root'
    exit 1
fi

configs=(
    /etc/snapshots.conf
    ~/.config/snapshots/config
)

for cfg in "${configs[@]}"; do
    if [ -f "$cfg" ]; then
        . "$cfg"
    fi
done

eval "$(findmnt -PT / -o +FSROOT)"

# Remove [/subvol] from source to get partition
PART=${SOURCE/\[*\]/}
FSROOT=${FSROOT##/}
FSROOT=${FSROOT%%/}

# Where to mount btrfs root
MOUNT_PATH=${MOUNT_PATH:-/mnt/btroot}
MOUNT_PATH=${MOUNT_PATH##/}
MOUNT_PATH=${MOUNT_PATH%%/}

# Snapshot subvolume (relative to btrfs root)
SNAPSHOTS=${SNAPSHOTS:-snapshots}
SNAPSHOTS=${SNAPSHOTS##/}
SNAPSHOTS=${SNAPSHOTS%%/}

: "${FSROOT:?Cannot find root subvolume}"
: "${SNAPSHOTS:?Required config SNAPSHOTS not set}"
: "${MOUNT_PATH:?Required config MOUNT_PATH not set}"

sid=$(date -u +%Y%m%dT%H%M%S%Z)
sdir=/$MOUNT_PATH/$SNAPSHOTS/root
spath=$sdir/${sid}

echo "[$0] Subvolume: /$MOUNT_PATH/$FSROOT"
echo "[$0] Snapshot: $spath"

unmount() {
    if findmnt "/$MOUNT_PATH" 1>/dev/null 2>&1; then
        umount -v "/$MOUNT_PATH"
    fi
}

mount -vmo subvolid=5 "$PART" "/$MOUNT_PATH"
trap unmount EXIT

mkdir -vp "$sdir"
btrfs -v subvolume snapshot -r "/$MOUNT_PATH/$FSROOT" "$spath"
