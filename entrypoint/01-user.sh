#!/bin/bash
# Create the 'amp' system user/group with the configured UID/GID.

echo "[01-user] Configuring user amp (UID=${UID}, GID=${GID})"

# Create group if needed
if ! getent group amp > /dev/null 2>&1; then
    groupadd --gid "${GID}" amp
else
    groupmod --gid "${GID}" amp
fi

# Create user if needed
if ! getent passwd amp > /dev/null 2>&1; then
    useradd \
        --uid "${UID}" \
        --gid "${GID}" \
        --home /home/amp \
        --shell /bin/bash \
        --no-create-home \
        amp
else
    usermod --uid "${UID}" --gid "${GID}" amp
fi

# Ensure home dir exists and is owned correctly
mkdir -p /home/amp/.ampdata
chown -R amp:amp /home/amp

echo "[01-user] Done."
