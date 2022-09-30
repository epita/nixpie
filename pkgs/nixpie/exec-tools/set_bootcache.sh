#! /usr/bin/env bash

set -euo pipefail

echo "Scanning disks on your system:"
disks="$(lsblk --list --noheadings --paths --output NAME,SIZE,TYPE | grep ' disk')"

echo "${disks}" | while read name size; do
  echo "  - ${name} (${size})"
done

if [ -z "${disks}" ]; then
  echo "Error: no disk found!"
  exit 1
fi

if [ "$(echo "${disks}" | wc -l)" -ne 1 ]; then
  DISK_NAME="/dev/invalid"

  while [ ! -b "${DISK_NAME}" ]; do
    echo -n "Choose a disk: "
    read -r DISK_NAME
  done
else
  DISK_NAME="$(echo "${disks}" | cut -d" " -f1)"
fi

echo "Setting partitions on ${DISK_NAME}"
echo "  - EFI (2G)"
echo "  - bootcache (32G)"
echo "  - nix-store-rw (32G)"
echo "ALL THIS DISK CONTENT WILL BE ERASED!"
echo "Press Ctrl+C to cancel..."
echo "Waiting 10 seconds before starting..."

sleep 10

sgdisk --zap-all "${DISK_NAME}"
sgdisk --clear "${DISK_NAME}"

sgdisk --new 1:2M:+2G "${DISK_NAME}"
sgdisk --change-name 1:EFI "${DISK_NAME}"
sgdisk --typecode 1:ef00 "${DISK_NAME}"

sgdisk --new 2:0:+32G "${DISK_NAME}"
sgdisk --change-name 2:bootcache "${DISK_NAME}"

sgdisk --new 3:0:+32G "${DISK_NAME}"
sgdisk --change-name 3:nix-store-rw "${DISK_NAME}"

partx --update "${DISK_NAME}"
sleep 5

mkfs.vfat -n EFI /dev/disk/by-partlabel/EFI
mkfs.ext4 -F -L bootcache /dev/disk/by-partlabel/bootcache
mkfs.ext4 -F -L nix-store-rw /dev/disk/by-partlabel/nix-store-rw
