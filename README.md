# agus4402/cubecoders-amp

> **Unofficial** community Docker image for [CubeCoders AMP](https://cubecoders.com/AMP) — a game server management panel.
> This image is NOT endorsed by CubeCoders. Do **not** contact CubeCoders for support with this image.

[![Docker Hub](https://img.shields.io/docker/pulls/agus4402/cubecoders-amp?logo=docker)](https://hub.docker.com/r/agus4402/cubecoders-amp)
[![GitHub Actions](https://img.shields.io/github/actions/workflow/status/agus4402/cubecoders-amp-docker/check-version.yml?label=auto-update&logo=github)](https://github.com/agus4402/cubecoders-amp-docker/actions)

---

## Tags

| Tag | Description |
|-----|-------------|
| `stable` | Always points to the latest published AMP version |
| `2.7.2.2` | Pinned to a specific AMP version (example) |

> `:latest` is intentionally not published — use `stable` or a version tag.

---

## Quick start

```bash
docker run -d \
  --name amp \
  --mac-address 02:42:ac:11:22:33 \
  -p 8080:8080 \
  -e USERNAME=admin \
  -e PASSWORD=changeme \
  -e LICENSE=your-license-key \
  -v amp-data:/home/amp/.ampdata \
  agus4402/cubecoders-amp:stable
```

Open `http://localhost:8080` in your browser.

---

## Docker Compose

```yaml
services:
  amp:
    image: agus4402/cubecoders-amp:stable
    mac_address: "02:42:ac:11:22:33"
    environment:
      - USERNAME=admin
      - PASSWORD=changeme
      - PORT=8080
      - TZ=America/Argentina/Buenos_Aires
      - LICENSE=your-license-key
    volumes:
      - amp-data:/home/amp/.ampdata
    ports:
      - "8080:8080"
      # - "25565:25565"   # Minecraft Java
      # - "19132:19132/udp"  # Minecraft Bedrock
    restart: unless-stopped

volumes:
  amp-data:
```

---

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `USERNAME` | `admin` | AMP admin username (set at first run) |
| `PASSWORD` | `password` | AMP admin password — **change this!** |
| `PORT` | `8080` | Web UI port |
| `TZ` | `Etc/UTC` | Container timezone (e.g. `America/New_York`) |
| `UID` | `1000` | User ID for file ownership inside the volume |
| `GID` | `1000` | Group ID for file ownership inside the volume |
| `MODULE` | `ADS` | AMP module to start (`ADS` = Application Deployment Server) |
| `LICENSE` | *(empty)* | Your CubeCoders license key. Without it, AMP runs in eval mode |

---

## MAC address — required for licensing

AMP ties its license to hardware identifiers. Docker assigns a new MAC address on every container restart by default, which triggers AMP's license deactivation.

**Always** set a fixed MAC address:

```bash
# Generate a random Docker-compatible MAC address
printf '02:42:ac:%02x:%02x:%02x\n' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256))
```

Use that value in:
- `docker run --mac-address 02:42:ac:xx:xx:xx`
- `mac_address: "02:42:ac:xx:xx:xx"` in `docker-compose.yml`

---

## Volumes

| Path | Description |
|------|-------------|
| `/home/amp/.ampdata` | All AMP data: instances, configs, game files. **Mount this as a named volume.** |

---

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| `8080` | TCP | AMP Web UI (configurable via `PORT`) |
| `25565` | TCP | Minecraft Java Edition (add as needed) |
| `19132` | UDP | Minecraft Bedrock Edition |
| `27015` | UDP | Source engine games (CS:GO, TF2, Garry's Mod) |

Map game server ports **before** starting the container — changes require a restart.

---

## How versioning works

A GitHub Actions workflow runs daily and checks `https://cubecoders.com/AMPVersions.json` for new AMP releases.
When a new version is detected, it automatically:
1. Builds the image with the new AMP core baked in
2. Pushes `agus4402/cubecoders-amp:{version}` and `agus4402/cubecoders-amp:stable`

You can also build locally for a specific version:

```bash
docker build --build-arg AMP_VERSION=2.7.2.2 -t my-amp:2.7.2.2 .
```

---

## Support

- Issues with this Docker image → [open an issue](https://github.com/agus4402/cubecoders-amp-docker/issues)
- Issues with AMP itself → [CubeCoders Support](https://discourse.cubecoders.com/)
- **Do NOT contact CubeCoders about this Docker image**

---

## License

MIT — see [LICENSE](LICENSE)
