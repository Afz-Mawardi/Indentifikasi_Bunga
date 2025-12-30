# Indentifikasi Bunga (Flask)

Proyek Flask minimal untuk upload gambar dan (opsional) klasifikasi.

## Setup

```bash
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

## Run

```bash
python app.py
```

Buka: http://127.0.0.1:5000

## Catatan Model

Aplikasi ini sudah siap menerima pipeline model, tapi default-nya masih **placeholder**.
Jika kamu ingin klasifikasi nyata, tambahkan model + label mapping di folder `models/` lalu sesuaikan loader di `app.py`.
