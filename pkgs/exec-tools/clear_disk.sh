#! /usr/bin/env bash

set -euo pipefail

echo "Scanning disks on your system:"
disks="$(@lsblk_bin@ --list --noheadings --paths --output NAME,SIZE,TYPE | @grep_bin@ ' disk')"

echo "${disks}" | while read name size; do
  echo "  - ${name} (${size})"
done

if [ -z "${disks}" ]; then
  echo "Error: no disk found!"
  exit 1
fi

if [ "$(echo "${disks}" | @wc_bin@ -l)" -ne 1 ]; then
  DISK_NAME="/dev/invalid"

  while [ ! -b "${DISK_NAME}" ]; do
    echo -n "Choose a disk: "
    read -r DISK_NAME
  done
else
  DISK_NAME="$(echo "${disks}" | @cut_bin@ -d" " -f1)"
fi

echo "Deleting partitions on ${DISK_NAME}"
echo "ALL THIS DISK CONTENT WILL BE ERASED!"
echo "Press Ctrl+C to cancel..."
echo "Waiting 10 seconds before starting..."

sleep 10

@sgdisk_bin@ --zap-all "${DISK_NAME}"
@sgdisk_bin@ --clear "${DISK_NAME}"

@partx_bin@ --update "${DISK_NAME}"
sleep 5
