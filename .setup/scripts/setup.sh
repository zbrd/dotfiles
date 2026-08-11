#!/usr/bin/env bash

# Should be run inside arch-chroot
#
# Assumes:
# 1. using kernel linux-zen

set -e

if [[ "$EUID" != 0 ]]; then
    echo 'Must run as root'
    exit 1
fi

NAME=${1:-zb}
HOST=${2:-zbr}
ZONE=${3:-Asia/Kuala_Lumpur}

eval "$(lsblk -Po UUID /dev/sda2)"

: "${NAME:?NAME env var empty}"
: "${HOST:?HOST env var empty}"
: "${ZONE:?ZONE env var empty}"
: "${UUID:?Cannot find UUID of /dev/sda2}"

# Time
echo "Setting timezone '$ZONE'"
ln -vsf "/usr/share/zoneinfo/$ZONE" /etc/localtime
hwclock -v --systohc
systemctl enable systemd-timesyncd.service

# Localization
locales=('en_GB.UTF-8 UTF-8' 'en_US.UTF-8 UTF-8')
echo "Generating locales: ${locales[*]}"
cat > /etc/locale.gen <<EOF
# added by zb arch install scripts
# a list of supported locales is given in /usr/share/i18n/SUPPORTED
EOF
for l in "${locales[@]}"; do
    echo "$l" >> /etc/locale.gen
done
locale-gen

# Hostname and terminal configs
echo "Setting up hostname '$HOST'"
echo "$HOST" > /etc/hostname
echo "127.0.1.1 $HOST" >> /etc/hosts
echo 'FONT=term-128b' > /etc/vconsole.conf

# systemd-resolved
# https://wiki.archlinux.org/title/Systemd-resolved
echo 'Configuring systemd-resolved'
mkdir -vp /etc/systemd/resolved.conf.d
dns=(
    '9.9.9.9#dns.quad9.net'
    '149.112.112.112#dns.quad9.net'
    '2620:fe::fe#dns.quad9.net'
    '2620:fe::9#dns.quad9.net'
)
cat > /etc/systemd/resolved.conf.d/dns_over_tls.conf <<EOF
# added by zb arch install scripts
# https://wiki.archlinux.org/title/Systemd-resolved#Global_DNS_over_TLS
[Resolve]
DNS=${dns[@]}
DNSOverTLS=true
Domains=~.
EOF
systemctl enable systemd-resolved.service

# iwd
# https://wiki.archlinux.org/title/Iwd
echo 'Configuring iwd'
mkdir -vp /etc/iwd
cat > /etc/iwd/main.conf <<EOF
# added by zb arch install scripts
# https://wiki.archlinux.org/title/Iwd#Enable_built-in_network_configuration
[General]
EnableNetworkConfiguration=true

[Network]
EnableIPv6=true
NameResolvingService=systemd
EOF
systemctl enable iwd.service

# keyd
# https://github.com/rvaiya/keyd
systemctl enable keyd.service

# KMSCON
# https://wiki.archlinux.org/title/KMSCON
echo 'Setting up KMSCON'
mkdir -vp /etc/kmscon
cat > /etc/kmscon/kmscon.conf <<EOF
# added by zb arch install scripts
font-size=20
font-name=Iosevka Extended
login=/usr/bin/login -p -f $NAME
EOF
systemctl disable getty@.service
systemctl enable kmsconvt@.service

# TLP
# https://wiki.archlinux.org/title/TLP
echo 'Setting up TLP'
systemctl enable tlp.service
systemctl mask systemd-rfkill.service
systemctl mask systemd-rfkill.socket

# reflector
systemctl enable reflector.service

# Move scripts
echo 'Installing scripts'
mkdir -vp /etc/profile.d /etc/initcpio/post /etc/pacman.d/hooks
mv -v "$(dirname "$0")/userdefaults.sh" /etc/profile.d/
mv -v "$(dirname "$0")/efi.sh" /etc/initcpio/post/
mv -v "$(dirname "$0")/snapshot.sh" /usr/bin/snapshot-root
mv -v "$(dirname "$0")/snapshot.hook" /etc/pacman.d/hooks/99-snapshots.hook
chmod -v 755 /etc/initcpio/post/efi.sh /usr/bin/snapshot-root

# regenerate initramfs (and copy to EFI)
echo 'Regenerating initramfs'
mkinicpio -P

# users and groups
echo 'Setting up user and groups'
groupadd data
chown -vR :data /data
useradd -mG wheel,data "$NAME"
echo 'Set root password'
passwd
echo "Set $NAME password"
passwd "$NAME"

# add boot
echo 'Setting up EFI boot'
flags='rw,relatime,compress=zstd:3,ssd,discard=async,space_cache=v2'
flags+=",subvol=/@"
loader=/EFI/arch/vmlinuz-linux-zen
init=/EFI/arch/initramfs-linux-zen.img
boot='quiet loglevel=3 systemd.show_status=auto rd.udev.log_level=3'
efibootmgr \
    --create \
    --unicode \
    --label 'Arch Linux' \
    --loader "$loader" \
    "root=UUID=$UUID rootflags=$flags initrd=${init} ${boot}"

# create 'init' snapshot
echo 'Snapshotting initial subvolumes'
mount -v /mnt/btroot
btrfs -v subvolume snapshot -r /mnt/broot/@ /mnt/snapshots/root_init
btrfs -v subvolume snapshot -r /mnt/broot/@home /mnt/snapshots/home_init
umount -v /mnt/btroot

echo
echo 'Done. Manually unmount /mnt and reboot!'
