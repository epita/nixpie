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

PAYLOAD=$(cat <<EOF
{
  "fqdn": "$(hostname -f)",
  "computer": {
    "vendor": "$(echo "$DMIINFO" | grep "Manufacturer" | sed -E 's/^\s+[^:]+:\s+//')",
    "model": "$(echo "$DMIINFO" | grep "Product Name" | sed -E 's/^\s+[^:]+:\s+//')",
    "version": "$(echo "$DMIINFO" | grep "Version" | sed -E 's/^\s+[^:]+:\s+//')",
    "sku": "$(echo "$DMIINFO" | grep "SKU Number" | sed -E 's/^\s+[^:]+:\s+//')",
    "serialNumber": "$(echo "$DMIINFO" | grep "Serial Number" | sed -E 's/^\s+[^:]+:\s+//')"
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
