#! /usr/bin/env bash 

set -x

if [ -e "/proc/cmdline" ]; then

	cmdline=$(cat /proc/cmdline)

	if grep -q "nixosConfiguration=" <<< "$cmdline"; then
		CONFIG=$(grep -oP '(?<=nixosConfiguration=)[^ ]+' <<< "$cmdline")
	fi
	
fi

if [ -z $CONFIG ]; then

	NIXPIE_CONFIGS="$(nix flake show --json git+https://gitlab.cri.epita.fr/cri/infrastructure/nixpie.git | jq -r '.nixosConfigurations | keys[]' | grep -vE '(-local|-vm)$' | nl -w2 | tr '\t' ' ' | tr '\n' ' ')";

	CHOICE=$(dialog --clear --menu "Please select a configuration:" 0 0 25 $NIXPIE_CONFIGS 2>&1 >/dev/tty)


	CONFIG=$(awk -v num="$CHOICE" '{for(i=1; i <=NF; i+= 2) {if($i == num) print $(i+1)}}' <<< "$NIXPIE_CONFIGS")

fi

DISKS="$(lsblk -o NAME,SIZE -d -p -n -e7 | awk '{print "\""$1"\"" " \"" $2"\""}')"

DISK_COUNT=$(echo "$DISKS" | wc -w)

if [ "$DISK_COUNT" -eq 2 ]; then
	DISK=$(echo "$DISKS" | awk '{print $1}' | sed 's/"//g')
else
	DISK=$(dialog --clear --menu "Please select a disk:" 0 0 25 $DISKS 2>&1 >/dev/tty)

	DISK=$(echo "$DISK" | sed 's/"//g')
fi

if [[ "$DISK" == nvme* ]]; then
	PREFIX="${DISK}p"
else
	PREFIX="${DISK}"
fi

# Partition the disk
parted -s "${DISK}" mklabel gpt
parted -s "${DISK}" mkpart primary fat32 1MiB 1GB
parted -s "${DISK}" mkpart primary linux-swap 1GB 9GB
parted -s "${DISK}" mkpart primary ext4 9GB 100%

sleep 3
partprobe

parted -s "${DISK}" set 1 esp on

# Format the disks
mkfs.fat -n EFI -F 32 "${PREFIX}1"
mkswap "${PREFIX}2"
swaplabel -L 'nixos-swap' "${PREFIX}2"
mkfs.ext4 -L 'nixos-root' "${PREFIX}3"

sleep 3

# Mount the disk
mkdir -p /mnt
mount /dev/disk/by-label/nixos-root /mnt

mkdir -p /mnt/boot
mount /dev/disk/by-label/EFI /mnt/boot

nixos-install --no-root-passwd --flake git+https://gitlab.cri.epita.fr/cri/infrastructure/nixpie.git#${CONFIG}-local
