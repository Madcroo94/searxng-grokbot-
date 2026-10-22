# Grok Bot VM bundle (SearXNG + Camoufox)

This directory is a VM-ready bundle that runs both repositories together:

- **SearXNG** from `Madcroo94/searxng-grokbot-`
- **Camoufox** runtime from `Madcroo94/camoufox-grokbot` (via Python package)

## What it starts

- `searxng-core` on `http://<vm-ip>:8080`
- `valkey` for SearXNG limiter/session support
- `camoufox-server` websocket endpoint on `ws://<vm-ip>:9222/camoufox`

## Quick start

```bash
cd vm-box
cp .env.example .env
# Edit core-config/settings.yml and set a strong server.secret_key
docker compose up -d --build
```

## Validate

```bash
docker compose ps
curl -fsS "http://127.0.0.1:8080" >/dev/null && echo "SearXNG is up"
```

Camoufox endpoint:

```text
ws://127.0.0.1:9222/camoufox
```

## Notes for VM usage

- Open inbound ports `8080` and `9222` in your VM firewall/security group.
- Keep `core-config/settings.yml` and `.env` persisted on disk.
- For production, change `server.secret_key` before first public launch.
