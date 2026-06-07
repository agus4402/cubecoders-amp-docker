#!/bin/bash
# Initialize AMP instance on first run.
# Uses ampinstmgr --ShowInstancesList to verify the instance really exists.

LICENSE_ARG="${LICENSE:-none}"

echo "[03-amp-setup] Checking if AMP instance 'Main' exists..."

INSTANCES=$(su amp -c "ampinstmgr --ShowInstancesList" 2>&1 || true)
echo "[03-amp-setup] Current instances: ${INSTANCES:-none}"

if echo "${INSTANCES}" | grep -qi "\bMain\b"; then
    echo "[03-amp-setup] Instance 'Main' found. Skipping init."
    return 0
fi

echo "[03-amp-setup] First run — creating AMP instance (module: ${MODULE}, port: ${PORT})"

if [ -z "${LICENSE}" ]; then
    echo "[03-amp-setup] WARNING: LICENSE not set. AMP will run in eval mode."
    LICENSE_ARG="none"
fi

if [ "${PASSWORD}" = "password" ]; then
    echo "[03-amp-setup] WARNING: Using default password. Change it after first login!"
fi

# Full positional syntax: Module InstanceName IPBinding Port LicenceKey Username Password
CREATE_OUTPUT=$(su amp -c "ampinstmgr CreateInstance '${MODULE}' Main '0.0.0.0' '${PORT}' '${LICENSE_ARG}' '${USERNAME}' '${PASSWORD}'" 2>&1)
echo "${CREATE_OUTPUT}" | sed 's/^/[ampinstmgr] /'

if echo "${CREATE_OUTPUT}" | grep -qi "\[Error"; then
    echo "[03-amp-setup] ERROR: CreateInstance reported errors. Check logs above."
    exit 1
fi

echo "[03-amp-setup] AMP instance created successfully."
