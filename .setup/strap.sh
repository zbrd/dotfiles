#!/usr/bin/env bash

set -e

echo 'Assumes EFI partition already exist.'
echo 'Destroys existing root parition.'
echo
echo 'Things to do manually before this:'
echo '1. Remove old EFI boot entries'
echo '2. Create partitions if necessary'
echo '3. Check wlan0 interface is okay'
echo
echo 'PRESS CTRL+C TO EXIT NOW'
echo 'PRESS ANY KEY TO CONTINUE'
read -rn1

if [[ "$EUID" != 0 ]]; then
    echo 'Must run as root'
    exit 1
fi

# Set console font
FONT=${FONT:-ter-128b}
echo "Setting console font '$FONT'"
setfont -v "$FONT"

# Connect to internet
if [ -n "$WIFI" ]; then
    read -r wname wpass <<< "$WIFI"
    echo "Connecting to WiFi '$wname'"
    iwctl station wlan0 connect "$wname" "${wpass:+-P $wpass}"
else
    echo 'No wifi network name provided:'
    echo "export WIFI='<name> <password>'  # or"
    echo "WIFI='<name> <password>' ./$0"
    exit 1
fi

# Mount EFI partition
# NOTE: assuming EFI partition already exist.
EFI_DISK=${EFI_DISK:-/dev/sda1}
echo "Mounting EFI partition '$EFI_DISK'"
mount -vm "$EFI_DISK" /mnt/efi

# Create root partition
# NOTE: will destroy existing parition
# https://gist.github.com/mjkstra/96ce7a5689d753e7a6bdd92cdc169bae
ROOT_DISK=${ROOT_DISK:-/dev/sda2}
echo "Creating btrfs parition '$ROOT_DISK'"
mkfs.btrfs -vL Arch "$ROOT_DISK"
mount -v "$ROOT_DISK" /mnt
echo "Creating btrfs subvolumes"
btrfs -v subvolume create \
    /mnt/@ \
    /mnt/@home \
    /mnt/@data \
    /mnt/@var_log \
    /mnt/@var_cache \
    /mnt/@swap \
    /mnt/snapshots \
umount -v /mnt
mntopts=compress=zstd
mount -vmo "$mntopts,subvol=@" "$ROOT_DISK" /mnt
mount -vmo "$mntopts,subvol=@home" "$ROOT_DISK" /mnt/home
mount -vmo "$mntopts,subvol=@data" "$ROOT_DISK" /mnt/data
mount -vmo "$mntopts,subvol=@var_log" "$ROOT_DISK" /mnt/var/log
mount -vmo "$mntopts,subvol=@var_cache" "$ROOT_DISK" /mnt/var/cache
mount -vmo "$mntopts,subvol=@swap" "$ROOT_DISK" /mnt/swap
mount -vmo "$mntopts,subvolid=5,noauto" "$ROOT_DISK" /mnt/mnt/btroot
SWAP_SIZE=${SWAP_SIZE:-16g}
echo "Creating swapfile/subvolume ($SWAP_SIZE)"
btrfs -v filesystem mkswapfile --size "$SWAP_SIZE" --uuid clear \
    /mnt/swap/swapfile
swapon -v /mnt/swap/swapfile

PKGS=(
    base
    base-devel
    bash-completion
    btrfs-progs
    efibootmgr
    git
    gnupg
    intel-ucode
    iwd
    keyd
    kmscon
    linux-firmware
    linux-zen
    linux-zen-docs
    linux-zen-headers
    man-db
    neovim
    openssh
    pass
    reflector
    sudo
    systemd-resolvconf
    terminus-font
    tlp
    tmux
    tree
    udiskie
)

# Bootstrap
echo 'Set up pacman mirrorlist'
reflector \
    --latest 5 \
    --protocol https \
    --age 12 \
    --sort rate \
    --save /etc/pacman.d/mirrorlist
pacstrap -K /mnt "${PKGS[@]}"
genfstab -U /mnt >> /mnt/etc/fstab

# Copy scripts
echo 'Copying scripts'
cp -v "$(dirname "$0")"/scripts/* /mnt/root/

echo
echo 'Done! Verify everything is okay, then...'
echo "run 'arch-chroot -S /mnt /root/setup.sh <username>' to continue."
