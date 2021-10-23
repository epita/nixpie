#! /usr/bin/env bash

set -euo pipefail

IMAGE_NAME=$(cat /proc/cmdline | sed "s/.*dump_image=\([^ ]*\).*/\1/")
DISK_NAME=$(cat /proc/cmdline | sed "s/.*dump_disk=\([^ ]*\).*/\1/")

NFS_SERVER=clone-store.pie.cri.epita.fr
NFS_DIR=/

echo "Starting dump of image ${IMAGE_NAME}..."

echo "Mounting ${NFS_SERVER}:${NFS_DIR}..."
mkdir -p /home/partimag
mount -t nfs -o ro "${NFS_SERVER}:${NFS_DIR}" /home/partimag
echo "Finished mounting"

echo "Dumping image..."
dd if=/dev/zero of="/dev/${DISK_NAME}" count=10
partprobe
clonezilla ocs-sr -icds -g auto -e1 auto -e2 -r -j2 -scr -p choose restoredisk "${IMAGE_NAME}" "${DISK_NAME}"
echo "Dump done"
