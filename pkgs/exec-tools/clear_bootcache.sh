#! /usr/bin/env bash

set -euo pipefail

BOOTCACHE_PARTITION="/dev/disk/by-partlabel/bootcache"

if [ ! -b "${BOOTCACHE_PARTITION}" ]; then
  echo "No bootcache partition found. Exiting..."
  exit 0
fi

mkfs.ext4 -F -L bootcache "${BOOTCACHE_PARTITION}"
