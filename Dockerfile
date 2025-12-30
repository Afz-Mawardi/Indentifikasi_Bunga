# syntax=docker/dockerfile:1

# Base image dengan TensorFlow CPU yang kompatibel dan stabil untuk inference
FROM tensorflow/tensorflow:2.15.0

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TF_CPP_MIN_LOG_LEVEL=2

WORKDIR /app

# OpenCV runtime deps (cv2 import) + minimal
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libgl1 \
        libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install Python deps (dipin untuk reproducibility di Docker)
# NOTE: requirements.txt di repo bersifat >=; di Docker kita pin agar build konsisten.
COPY requirements.txt /app/requirements.txt
RUN python -m pip install --upgrade pip \
    && python -m pip install --no-cache-dir \
        Flask==2.3.3 \
        numpy==1.26.4 \
        Pillow==10.4.0 \
        opencv-python==4.8.0.76 \
        keras==2.15.0 \
        gunicorn==21.2.0

# Copy source
COPY . /app

# Jalankan sebagai non-root (lebih aman)
RUN useradd -m -u 10001 appuser \
    && chown -R appuser:appuser /app
USER appuser

EXPOSE 5000

# Production entrypoint (debug=False)
# 1 worker karena TensorFlow model biasanya berat; threads untuk concurrency ringan.
CMD ["gunicorn", "-w", "1", "-k", "gthread", "--threads", "4", "--timeout", "120", "-b", "0.0.0.0:5000", "app:app"]
