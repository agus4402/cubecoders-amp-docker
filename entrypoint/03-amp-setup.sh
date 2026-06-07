#!/bin/bash
# Initialize AMP instance on first run.
# On subsequent runs the existing data volume is reused unchanged.

INSTANCE_DIR="/home/amp/.ampdata"
INSTANCE_MARKER="${INSTANCE_DIR}/.amp_initialized"

echo "[03-amp-setup] Checking AMP initialization..."

if [ -f "${INSTANCE_MARKER}" ]; then
    echo "[03-amp-setup] Existing AMP instance found, skipping init."
    return 0
fi

echo "[03-amp-setup] First run — creating AMP instance (module: ${MODULE})"

if [ -z "${LICENSE}" ]; then
    echo "[03-amp-setup] WARNING: LICENSE is not set. AMP will run in eval mode."
fi

if [ "${PASSWORD}" = "password" ]; then
    echo "[03-amp-setup] WARNING: Using default password. Change it after first login!"
fi

# ampinstmgr uses Console.SetCursorPosition for interactive prompts, which
# requires a TTY. We use 'script' to provide a fake PTY so it doesn't crash
# when Docker is started without --tty / tty:true.
AMPINSTMGR_CMD="ampinstmgr CreateInstance '${MODULE}' Main '${LICENSE}' '${USERNAME}' '${PASSWORD}' console"

su amp -c "script -q -c \"${AMPINSTMGR_CMD}\" /dev/null" 2>&1 \
    | sed 's/^/[ampinstmgr] /'

EXIT_CODE=${PIPESTATUS[0]}

if [ "${EXIT_CODE}" -ne 0 ]; then
    echo "[03-amp-setup] ERROR: ampinstmgr exited with code ${EXIT_CODE}. Check the logs above."
    exit "${EXIT_CODE}"
fi

# Patch the port in the instance config if non-default
if [ "${PORT}" != "8080" ]; then
    CONFIG_FILE="${INSTANCE_DIR}/AMP/Instances/Main/AMPConfig.conf"
    if [ -f "${CONFIG_FILE}" ]; then
        sed -i "s/AMP.Primary.Port=.*/AMP.Primary.Port=${PORT}/" "${CONFIG_FILE}" || true
    fi
fi

touch "${INSTANCE_MARKER}"
echo "[03-amp-setup] AMP instance created successfully."
