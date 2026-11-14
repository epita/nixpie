#!/usr/bin/env bash

# The images leave networking.hostName empty, so the hostname comes from the
# DHCP lease: systemd-networkd hands it to systemd-hostnamed as a *transient*
# hostname, which happens asynchronously after network-online.target is
# reached -- ordering alone cannot wait for it. Until it lands, hostnamed
# reports the source as "default" (networking.hostName's own default,
# config.system.nixos.distroId). A machine unknown to the DHCP server stays
# at "default" forever, so the wait is bounded -- we then report under the
# generic hostname, which the API accepts, and the DMI serial number below
# still identifies the machine.
HOSTNAME_TIMEOUT=${HOSTNAME_TIMEOUT:-90}

hostname_source() {
    busctl --no-pager get-property \
        org.freedesktop.hostname1 /org/freedesktop/hostname1 \
        org.freedesktop.hostname1 HostnameSource 2>/dev/null |
        sed -nE 's/^s "(.*)"$/\1/p'
}

wait_for_hostname() {
    local deadline=$((SECONDS + HOSTNAME_TIMEOUT))

    while [ "$SECONDS" -lt "$deadline" ]; do
        case "$(hostname_source)" in
            transient|static) return 0 ;;
        esac
        sleep 2
    done

    return 1
}

# The search domain comes from the same lease (dhcpV4Config.UseDomains), but
# resolved may not have applied it yet, in which case `hostname -f` returns the
# short name. Retry briefly, then settle for whatever we have.
resolve_fqdn() {
    local deadline=$((SECONDS + 20)) fqdn

    while :; do
        fqdn=$(hostname -f 2>/dev/null)
        [ -n "$fqdn" ] || fqdn=$(hostname)
        case "$fqdn" in
            *.*) break ;;
        esac
        [ "$SECONDS" -lt "$deadline" ] || break
        sleep 2
    done

    printf '%s\n' "$fqdn"
}

if wait_for_hostname; then
    FQDN=$(resolve_fqdn)
else
    # Nothing to resolve: no DHCP hostname means no DHCP search domain either,
    # so skip the retries and report under the generic hostname.
    FQDN=$(hostname)
    echo "No hostname after ${HOSTNAME_TIMEOUT}s, reporting as '${FQDN}': the machine is most likely not registered on the DHCP server." >&2
fi

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
  "fqdn": "$FQDN",
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
