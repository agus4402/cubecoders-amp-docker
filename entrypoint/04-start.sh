#!/bin/bash
# Start AMP and keep the container alive by tailing its process.

echo "[04-start] Starting AMP instance 'Main'..."

su amp -c "ampinstmgr StartBoot Main" 2>&1 | sed 's/^/[ampinstmgr] /'

echo "[04-start] AMP started. Monitoring process..."

# Keep the container alive; if AMP dies, so does the container (allows restart policies to kick in)
while su amp -c "ampinstmgr Status Main" 2>/dev/null | grep -q "Running"; do
    sleep 10
done

echo "[04-start] AMP instance stopped. Exiting container."
exit 1
