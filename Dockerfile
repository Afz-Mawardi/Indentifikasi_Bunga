# Dockerfile for Railway / container deployment
# - Pins Python to a TensorFlow-compatible version
# - Uses Gunicorn (production WSGI) and respects PORT

FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    TF_CPP_MIN_LOG_LEVEL=2

WORKDIR /app

# System deps:
# - libglib2.0-0: commonly required by opencv-python-headless wheels
# - libgomp1: required by some ML wheels (OpenMP)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libglib2.0-0 \
        libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Install Python deps first for better layer caching
COPY requirements.txt ./
RUN pip install --upgrade pip \
    && pip install -r requirements.txt \
    && pip install gunicorn

# Copy app code
COPY . ./

# Railway sets PORT; default to 5000 for local docker run
EXPOSE 5000

# Keep a single worker by default to avoid loading the TF model multiple times.
# You can override by setting WEB_CONCURRENCY.
CMD ["sh", "-c", "gunicorn -w ${WEB_CONCURRENCY:-1} -b 0.0.0.0:${PORT:-5000} --timeout ${GUNICORN_TIMEOUT:-120} app:app"]
