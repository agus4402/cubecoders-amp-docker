#!/bin/bash
set -euo pipefail

ENTRYPOINT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo " CubeCoders AMP — Community Docker Image"
echo " https://github.com/agus4402/cubecoders-amp-docker"
echo " NOT endorsed by CubeCoders. Do NOT contact"
echo " CubeCoders for support with this image."
echo "=========================================="
echo ""
echo "AMP version baked: $(cat /amp-version 2>/dev/null || echo 'unknown')"
echo ""

# Graceful shutdown: forward SIGTERM/SIGINT to the AMP process
_shutdown() {
    echo "[main] Shutting down AMP..."
    su amp -c "ampinstmgr --StopInstance Main" 2>/dev/null || true
    exit 0
}
trap _shutdown SIGTERM SIGINT

source "$ENTRYPOINT_DIR/01-user.sh"
source "$ENTRYPOINT_DIR/02-timezone.sh"
source "$ENTRYPOINT_DIR/03-amp-setup.sh"
source "$ENTRYPOINT_DIR/04-start.sh"
