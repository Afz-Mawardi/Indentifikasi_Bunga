# syntax=docker/dockerfile:1

# Base image Python bersih untuk menghindari konflik package bawaan OS
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TF_CPP_MIN_LOG_LEVEL=2

WORKDIR /app

# OpenCV runtime deps (cv2 import) + minimal
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libgl1 \
        libglib2.0-0 \
        libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Install Python deps
COPY requirements.txt /app/requirements.txt
RUN python -m pip install --upgrade pip \
    && python -m pip install --no-cache-dir -r /app/requirements.txt

# Copy source
COPY . /app

# Jalankan sebagai non-root (lebih aman)
RUN useradd -m -u 10001 appuser \
    && chown -R appuser:appuser /app
USER appuser

EXPOSE 5000

# Production entrypoint (debug=False)
# 1 worker karena TensorFlow model biasanya berat; threads untuk concurrency ringan.
CMD ["sh", "-c", "gunicorn -w 1 -k gthread --threads 4 --timeout 120 -b 0.0.0.0:${PORT:-5000} app:app"]
