# Grok Bot VM bundle (SearXNG + Camoufox)

Runs the two backends the Grok Bot crawler needs on one VM:

- **SearXNG** search API: the official `searxng/searxng` image, with JSON output turned on.
- **Camoufox** browser server: the `camoufox` package from PyPI (pinned), served over a Playwright websocket.

> This bundle does **not** build code from the `searxng-grokbot-` or `camoufox-grokbot` forks.
> Both forks currently match upstream, so the published image and package are the same code.

## What it starts

| Service | Default address | Use |
| --- | --- | --- |
| `searxng-core` | `http://127.0.0.1:8080` | `GET /search?q=<query>&format=json` |
| `camoufox-server` | `ws://127.0.0.1:9222/<CAMOUFOX_WS_PATH>` | Playwright `firefox.connect()` |

Both bind to `127.0.0.1` by default, so only the VM itself can reach them.

## Quick start

```bash
cd vm-box
cp .env.example .env
# Fill in the two required values:
sed -i "s/^SEARXNG_SECRET=.*/SEARXNG_SECRET=$(openssl rand -hex 32)/" .env
sed -i "s/^CAMOUFOX_WS_PATH=.*/CAMOUFOX_WS_PATH=$(openssl rand -hex 24)/" .env
docker compose up -d --build
```

`docker compose` stops with an error if either value is missing.

## Validate

```bash
docker compose ps
curl -fsS "http://127.0.0.1:8080/search?q=test&format=json" | head -c 300; echo
docker compose logs camoufox-server | grep -i "websocket endpoint"
```

## Connect the crawler

SearXNG (any HTTP client):

```bash
curl "http://127.0.0.1:8080/search?q=example&format=json"
```

Camoufox (Python Playwright; keep the client on a Playwright version below 1.63):

```python
import os
from playwright.sync_api import sync_playwright

ws = f"ws://127.0.0.1:9222/{os.environ['CAMOUFOX_WS_PATH']}"
with sync_playwright() as p:
    browser = p.firefox.connect(ws)
    page = browser.new_page()
    page.goto("https://example.com")
    print(page.title())
    browser.close()
```

## Crawler on another machine

Pick one:

- **SSH tunnel (simplest, nothing exposed):**
  `ssh -N -L 8080:127.0.0.1:8080 -L 9222:127.0.0.1:9222 user@<vm-ip>`
  then use the `127.0.0.1` addresses above on the crawler machine.
- **Private network:** set `SEARXNG_HOST` / `CAMOUFOX_HOST` in `.env` to the VM's
  private IP and allow only the crawler's IP in the cloud security group.
  Docker-published ports skip host firewalls like `ufw`, so the security group is the real gate.

Never bind these to `0.0.0.0` on a public IP: there is no login, and the
websocket path is the only thing protecting the browser.

## Notes

- Keep `.env` and `core-config/settings.yml` on persistent disk; don't commit `.env`.
- The SearXNG rate limiter is off (it would block the crawler). That is only safe
  while the instance stays private.
- `SEARXNG_VERSION=latest` pulls new SearXNG releases on `docker compose pull`; pin a tag for repeatable deploys.
