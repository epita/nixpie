#! /usr/bin/env bash

set -euo pipefail

clear_partition() {
  label="${1}"
  partition="/dev/disk/by-partlabel/${label}"

  if [ ! -b "${partition}" ]; then
    echo "No ${label} partition found. Exiting..."
    return
  fi

  mkfs.ext4 -F -L "${label}" "${partition}"
}

clear_partition bootcache
clear_partition nix-store-rw
