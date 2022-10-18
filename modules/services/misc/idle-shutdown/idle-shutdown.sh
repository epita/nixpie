#!/usr/bin/env bash
set -euo pipefail

# delay in seconds before shutdown after no user is logged
DELAY="${DELAY:-7200}"
IDLE_SINCE_PATH="/run/nixpie-idle-shutdown"

if ! grep -q 'sm\.cri\.epita\.fr' /etc/resolv.conf ; then
  echo "Not in machine room"
  exit
fi

# if someone is logged in
if loginctl list-sessions --no-pager --no-legend | grep -q -v sddm ; then
  echo "A user is logged in. Exiting."
  echo "" > "$IDLE_SINCE_PATH"
  exit
fi

IDLE_SINCE=$(cat "$IDLE_SINCE_PATH" 2>/dev/null || echo "")
CURRENT_TIME=$(date +%s)

if ! [ -f "$IDLE_SINCE_PATH" ] || [ -z "$IDLE_SINCE" ] ; then
  echo "No user is logged. Logging current time."
  echo "$CURRENT_TIME" > "$IDLE_SINCE_PATH"
  exit
fi

if [ "$(( CURRENT_TIME - IDLE_SINCE ))" -lt "$DELAY" ] ; then
  echo "Machine has not been idling for enough time. Exiting."
  exit
fi

echo "Machine has been idling for too long, checking if it can shutdown"
IP_NET=$(get_ip.sh | cut -d. -f1-3)
UP_COUNT=0
for ip in $(seq -f "${IP_NET}.%g" 2 250); do
    if ping -c 1 -q -W 1 "$ip" &>/dev/null ; then
        UP_COUNT=$((UP_COUNT + 1))
        if [ "$UP_COUNT" -ge 3 ] ; then
            poweroff
        fi
    fi
done
echo "Did not find enough up machines. Not powering off."
