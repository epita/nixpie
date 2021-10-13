#! /usr/bin/env bash

set -euo pipefail

IMAGE_NAME=$(cat /proc/cmdline | sed "s/.*dump_image=\([^ ]*\).*/\1/")
DISK_NAME=$(cat /proc/cmdline | sed "s/.*dump_disk=\([^ ]*\).*/\1/")

NFS_SERVER=clone-store-1.pie.cri.epita.net
NFS_DIR=/srv/nfs

echo "Creating dump ${IMAGE_NAME}..."

echo "Mounting ${NFS_SERVER}:${NFS_DIR}..."
mkdir -p /home/partimag
mount -t nfs "${NFS_SERVER}:${NFS_DIR}" /home/partimag
echo "Finished mounting"

echo "Creating dump..."
clonezilla ocs-sr -gs -j2 -rm-win-swap-hib -z2p -scr -p choose savedisk "${IMAGE_NAME}" "${DISK_NAME}"
echo "Dump done"
