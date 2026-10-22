FROM mcr.microsoft.com/playwright/python:v1.56.1-noble

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN pip install --no-cache-dir "camoufox[geoip]" && camoufox fetch

EXPOSE 9222

CMD ["python", "-c", "import os; from camoufox.server import launch_server; launch_server(headless=(os.getenv('CAMOUFOX_HEADLESS','true').lower()=='true'), port=int(os.getenv('CAMOUFOX_PORT','9222')), ws_path=os.getenv('CAMOUFOX_WS_PATH','camoufox'))"]
