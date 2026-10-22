# camoufox needs playwright<1.63; keep the base image on the same Playwright version.
FROM mcr.microsoft.com/playwright/python:v1.62.0-noble

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN pip install --no-cache-dir "camoufox[geoip]==0.5.8" "playwright==1.62.0" && camoufox fetch

EXPOSE 9222

# host=0.0.0.0: Playwright otherwise listens on loopback only, which Docker can't forward to.
# Outside access is still limited by the CAMOUFOX_HOST port binding in docker-compose.yml.
CMD ["python", "-c", "import os; from camoufox.server import launch_server; launch_server(headless=(os.getenv('CAMOUFOX_HEADLESS','true').lower()=='true'), host='0.0.0.0', port=int(os.getenv('CAMOUFOX_PORT','9222')), ws_path=os.environ['CAMOUFOX_WS_PATH'])"]
