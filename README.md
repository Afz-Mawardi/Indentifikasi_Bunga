# Flower AI — Klasifikasi Jenis Bunga (Flask + TensorFlow)

Aplikasi web untuk mengklasifikasikan jenis bunga dari gambar (upload file atau kamera), menampilkan confidence, serta menampilkan metadata/penjelasan bunga.

---

## Daftar Isi

- [Highlights](#highlights)
- [Tech Stack](#tech-stack)
- [Struktur Project](#struktur-project)
- [Requirements](#requirements)
- [Quickstart](#quickstart)
- [Konfigurasi & Batasan](#konfigurasi--batasan)
- [API Ringkas](#api-ringkas)
- [Production Notes](#production-notes)
- [License](#license)

## Highlights

- **Web UI** (HTML templates) untuk beranda, klasifikasi, dan pencarian.
- **API JSON** untuk:
  - upload gambar (`/upload`)
  - capture kamera (`/capture`)
  - pencarian metadata bunga (`/api/search`)
- **Model inference** menggunakan TensorFlow/Keras (`.keras`) dan utilitas prediksi di `models/model_utils.py`.
- **Validasi kualitas gambar** (brightness & blur) untuk mengurangi prediksi pada gambar yang tidak layak.

---

## Tech Stack

- Backend: **Flask**
- ML Inference: **TensorFlow** (memuat model Keras)
- Image processing: **Pillow**, **OpenCV**, **NumPy**

---

## Struktur Project

- `app.py` — Aplikasi Flask, routing, load model, load metadata, API.
- `models/`
  - `flower_classification_model_MobileNetV2.keras` — model terlatih.
  - `model_utils.py` — fungsi prediksi + quality check.
  - `cat_to_name.json` — mapping kelas -> nama bunga.
  - `class_indices.json` — mapping index model -> label folder (mapping training).
  - `flower_metadata.json` — metadata (nama ilmiah, habitat, dll).
- `templates/` — halaman UI (Jinja2): `index.html`, `clasify.html`, `search.html`.
- `static/` — asset front-end: `style.css`, `script.js`.

---

## Requirements

- Python: **3.10+** (pastikan kompatibel dengan versi TensorFlow yang di-install di OS kamu)
- Dependensi Python: lihat `requirements.txt`

---

## Quickstart

1) Buat dan aktifkan virtual environment

```bash
python -m venv .venv
# Windows PowerShell
.\.venv\Scripts\Activate.ps1
```

2) Install dependency

```bash
pip install -r requirements.txt
```

3) Jalankan server

```bash
python app.py
```

4) Buka di browser

- UI: `http://localhost:5000/`
- Klasifikasi: `http://localhost:5000/clasify`
- Search: `http://localhost:5000/search`

---

## Konfigurasi & Batasan

- Maks ukuran upload: **10 MB** (`MAX_CONTENT_LENGTH`).
- Ekstensi yang diizinkan: `png`, `jpg`, `jpeg`, `bmp`.
- File model dan metadata dibaca dari folder `models/`.
- Mapping kelas:
  - Utama: `models/class_indices.json` (mapping yang sama seperti saat training).
  - Fallback: folder dataset `../dataset/train` (jika tersedia).
  - Fallback terakhir: urutan key dari `models/cat_to_name.json`.

---

## API Ringkas

- `POST /upload` (multipart/form-data): field `file`
- `POST /capture` (JSON): `{ "image": "data:image/jpeg;base64,..." }`
- `POST /api/search` (JSON): `{ "query": "mawar" }`

Detail lengkap request/response dan contoh curl ada di `USAGE.md`.

---

## Production Notes

- Jangan jalankan dengan `debug=True` di production.
- Untuk deployment, jalankan via WSGI server pilihan Anda (mis. gunicorn/waitress) dan atur reverse proxy (Nginx/IIS) sesuai kebutuhan.
- Jika deploy di server/container tanpa GUI dan muncul error `ImportError: libGL.so.1`, gunakan dependency `opencv-python-headless` (sudah diset di `requirements.txt`).

---

## License

MIT License. Lihat file `LICENSE`.
# AI_Flower_Classifier
