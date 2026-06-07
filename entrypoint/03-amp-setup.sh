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

# Validate required variables
if [ -z "${LICENSE}" ]; then
    echo "[03-amp-setup] WARNING: LICENSE is not set. AMP will run in eval mode."
fi

if [ "${PASSWORD}" = "password" ]; then
    echo "[03-amp-setup] WARNING: Using default password. Change it after first login!"
fi

# ampinstmgr needs to run as the amp user
# Port configuration is passed via environment; AMP reads it on creation
su amp -c "ampinstmgr CreateInstance \
    '${MODULE}' \
    Main \
    '${LICENSE}' \
    '${USERNAME}' \
    '${PASSWORD}' \
    'console'" 2>&1 | sed 's/^/[ampinstmgr] /'

# Patch the port in the instance config if non-default
if [ "${PORT}" != "8080" ]; then
    CONFIG_FILE="${INSTANCE_DIR}/AMP/Instances/Main/AMPConfig.conf"
    if [ -f "${CONFIG_FILE}" ]; then
        sed -i "s/AMP.Primary.Port=.*/AMP.Primary.Port=${PORT}/" "${CONFIG_FILE}" || true
    fi
fi

touch "${INSTANCE_MARKER}"
echo "[03-amp-setup] AMP instance created successfully."
