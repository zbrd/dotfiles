#!/usr/bin/env bash

# Added by zb archlinux setup script
#
# This script copies the kernel and initramfs to the ESP directory
# after mkinicpio (re)generate the initramfs file.

if [[ "$EUID" != 0 ]]; then
    echo 'Must run as root'
    exit 1
fi

espdir="/efi/EFI/arch"
kernel="${1:?No kernel arg}"
initramfs="${2:?No initramfs arg}"
files=()

for f in "$kernel" "$initramfs"; do
    if [[ -n "$f" ]] && ! cmp -s -- "$f" "${espdir}/${f##*/}"; then
        files+=("$f")
    fi
done

if (( ! "${#files[@]}" )); then
    echo "[$0] nothing to copy"
    exit 0
fi

echo "[$0] files to copy: ${files[*]}"
echo "[$0] target ESP dir: ${espdir}"

# For testing
if (( "$NO_COPY" )); then
    exit 0
fi

mkdir -vp -- "${espdir}"
cp -vaf -- "${files[@]}" "${espdir}"
