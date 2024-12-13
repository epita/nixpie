#!/usr/bin/env bash

DMIINFO=$(dmidecode -t 1)
EDID=""
for edid in /sys/class/drm/*/edid ; do
    EDID=$(parse-edid < $edid)
    if [ -n "$EDID" ]; then
        break
    fi
done
DISPLAY_VENDOR=$(echo "$EDID" | grep VendorName | sed -E 's/^\s+[A-Za-z]+ "(.+)"$/\1/')
DISPLAY_MODEL=$(echo "$EDID" | grep ModelName | sed -E 's/^\s+[A-Za-z]+ "(.+)"$/\1/')

COMPUTER_VENDOR=$(echo "$DMIINFO" | grep "Manufacturer" | sed -E 's/^\s+[^:]+:\s+//')
COMPUTER_MODEL=$(echo "$DMIINFO" | grep "Product Name" | sed -E 's/^\s+[^:]+:\s+//')
COMPUTER_VERSION=$(echo "$DMIINFO" | grep "Version" | sed -E 's/^\s+[^:]+:\s+//')
COMPUTER_SKU=$(echo "$DMIINFO" | grep "SKU Number" | sed -E 's/^\s+[^:]+:\s+//')
COMPUTER_SERIAL_NUMBER=$(echo "$DMIINFO" | grep "Serial Number" | sed -E 's/^\s+[^:]+:\s+//')

DMIINFO=$(dmidecode -t 2)

if [ -z "$COMPUTER_VENDOR" ]; then
    COMPUTER_VENDOR=$(echo "$DMIINFO" | grep "Manufacturer" | sed -E 's/^\s+[^:]+:\s+//')
fi
if [ -z "$COMPUTER_MODEL" ]; then
    COMPUTER_MODEL=$(echo "$DMIINFO" | grep "Product Name" | sed -E 's/^\s+[^:]+:\s+//')
fi
if [ -z "$COMPUTER_VERSION" ]; then
    COMPUTER_VERSION=$(echo "$DMIINFO" | grep "Version" | sed -E 's/^\s+[^:]+:\s+//')
fi
if [ -z "$COMPUTER_SERIAL_NUMBER" ]; then
    COMPUTER_SERIAL_NUMBER=$(echo "$DMIINFO" | grep "Serial Number" | sed -E 's/^\s+[^:]+:\s+//')
fi

PAYLOAD=$(cat <<EOF
{
  "fqdn": "$(hostname -f)",
  "computer": {
    "vendor": "$COMPUTER_VENDOR",
    "model": "$COMPUTER_MODEL",
    "version": "$COMPUTER_VERSION",
    "sku": "$COMPUTER_SKU",
    "serialNumber": "$COMPUTER_SERIAL_NUMBER"
  },
  "display": {
    "vendor": "$DISPLAY_VENDOR",
    "model": "$DISPLAY_MODEL"
  }
}
EOF
)

echo "$PAYLOAD"

curl -v --fail -X 'POST' \
  'https://repo-sm-inventory.pie.forge.epita.fr/api/registration' \
  -H 'accept: */*' \
  -H 'Content-Type: application/json' -d "$PAYLOAD"
