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

DISK_HUMAN_SIZE="$(lsblk --nodeps -ln -o SIZE "${DISK_NAME}")"
DISK_SIZE="$(lsblk --nodeps -bln -o SIZE "${DISK_NAME}")"

if [ "${DISK_SIZE}" -le 64000000000 ]; then
  echo "Error: not enough space on device: ${DISK_NAME}"
  echo "You need at least 64GB"
  exit 1
fi

echo "Setting partitions on ${DISK_NAME}"
echo "  - bootcache (32G)"
echo "  - home (16G)"
echo "  - swap (8G)"
echo "ALL THIS DISK CONTENT WILL BE ERASED!"
echo "Press Ctrl+C to cancel..."
echo "Waiting 10 seconds before starting..."

sleep 10

sgdisk --zap-all "${DISK_NAME}"
sgdisk --clear "${DISK_NAME}"

sgdisk --new 1:2M:+32G "${DISK_NAME}"
sgdisk --change-name 1:bootcache "${DISK_NAME}"

sgdisk --new 2:0:+16G "${DISK_NAME}"
sgdisk --change-name 2:home "${DISK_NAME}"

sgdisk --new 3:0:+8G "${DISK_NAME}"
sgdisk --change-name 3:swap "${DISK_NAME}"

partx --update "${DISK_NAME}"
sleep 5

mkfs.ext4 -F -L bootcache /dev/disk/by-partlabel/bootcache
mkfs.ext4 -F -L home /dev/disk/by-partlabel/home
mkswap -f -L swap /dev/disk/by-partlabel/swap
