#!/bin/bash
# Configure the container timezone from the TZ environment variable.

echo "[02-timezone] Setting timezone to ${TZ}"

echo "${TZ}" > /etc/timezone
ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime
dpkg-reconfigure -f noninteractive tzdata 2>/dev/null || true

echo "[02-timezone] Done."
