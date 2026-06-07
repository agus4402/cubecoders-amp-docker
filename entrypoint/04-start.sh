#!/bin/bash
# Start the AMP instance and keep the container alive while it runs.

echo "[04-start] Starting AMP instance 'Main'..."

su amp -c "ampinstmgr --StartInstance Main" 2>&1 | sed 's/^/[ampinstmgr] /'

if [ "${PIPESTATUS[0]}" -ne 0 ]; then
    echo "[04-start] ERROR: failed to start AMP instance."
    exit 1
fi

echo "[04-start] AMP started. Monitoring process..."

# Poll every 10s; exit if the instance is no longer Running so Docker
# restart policies can recover it.
while true; do
    STATUS=$(su amp -c "ampinstmgr --ShowInstanceInfo Main" 2>/dev/null || true)
    if ! echo "${STATUS}" | grep -qi "running"; then
        echo "[04-start] AMP instance is no longer running. Exiting container."
        exit 1
    fi
    sleep 10
done
