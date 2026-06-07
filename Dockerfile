FROM debian:12-slim

ARG AMP_VERSION=latest

LABEL maintainer="agus4402" \
      org.opencontainers.image.title="CubeCoders AMP" \
      org.opencontainers.image.description="CubeCoders AMP game server management panel" \
      org.opencontainers.image.source="https://github.com/agus4402/cubecoders-amp-docker" \
      org.opencontainers.image.licenses="MIT"

ENV PORT=8080 \
    USERNAME=admin \
    PASSWORD=password \
    LICENSE="" \
    TZ=Etc/UTC \
    UID=1000 \
    GID=1000 \
    MODULE=ADS \
    AMP_SUPPORT_LEVEL=COMMUNITY \
    AMP_SUPPORT_TAGS="docker community unofficial" \
    AMP_SUPPORT_URL="https://github.com/agus4402/cubecoders-amp-docker" \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl wget jq git tmux socat unzip procps \
        gnupg ca-certificates tzdata libcurl4 \
        locales software-properties-common \
        iputils-ping \
    && sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Extract the ampinstmgr binary from the .deb without running its post-install
# scripts, which try to enable systemd services and fail inside Docker.
RUN curl -fsSL https://repo.cubecoders.com/archive.key \
        | gpg --dearmor -o /usr/share/keyrings/cubecoders.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/cubecoders.gpg] http://repo.cubecoders.com/ debian/" \
        > /etc/apt/sources.list.d/cubecoders.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends --download-only ampinstmgr \
    && mkdir -p /tmp/ampinstmgr \
    && dpkg-deb -x /var/cache/apt/archives/ampinstmgr_*.deb /tmp/ampinstmgr \
    && mv /tmp/ampinstmgr/opt/cubecoders/amp/ampinstmgr /usr/local/bin/ampinstmgr \
    && chmod +x /usr/local/bin/ampinstmgr \
    && rm -rf /tmp/ampinstmgr /var/lib/apt/lists/*

# Download and cache the AMP core zip at build time.
# If AMP_VERSION=latest, the current version is resolved from AMPVersions.json.
RUN set -e \
    && VERSIONS_JSON=$(wget -qO- "https://cubecoders.com/AMPVersions.json") \
    && if [ "$AMP_VERSION" = "latest" ]; then \
           AMP_VERSION=$(echo "$VERSIONS_JSON" | jq -r '.AMPCore'); \
       fi \
    && echo "$AMP_VERSION" > /amp-version \
    && SAFE_VER=$(echo "$AMP_VERSION" | tr -d '.') \
    && wget -q "https://cubecoders.com/Downloads/AMP_Latest.zip" \
         -O "/opt/AMPCache-${SAFE_VER}.zip" \
    && echo "AMP core $AMP_VERSION cached at /opt/AMPCache-${SAFE_VER}.zip"

# Copy entrypoint scripts
COPY entrypoint/ /opt/entrypoint/
RUN chmod -R +x /opt/entrypoint/

VOLUME ["/home/amp/.ampdata"]

EXPOSE 8080

ENTRYPOINT ["/opt/entrypoint/main.sh"]
