# Panduan Pemakaian — Flower AI

Dokumen ini menjelaskan cara memakai aplikasi (UI dan API), termasuk format request/response dan troubleshooting.

---

## Daftar Isi

- [Menjalankan Aplikasi (Local)](#menjalankan-aplikasi-local)
- [Menggunakan Web UI](#menggunakan-web-ui)
- [Menggunakan API](#menggunakan-api)
- [File Model & Metadata](#file-model--metadata)
- [Troubleshooting](#troubleshooting)
- [Catatan Keamanan](#catatan-keamanan)

## Menjalankan Aplikasi (Local)

### 1) Setup environment

```bash
python -m venv .venv
# Windows PowerShell
.\.venv\Scripts\Activate.ps1
```

### 2) Install dependency

```bash
pip install -r requirements.txt
```

### 3) Start server

```bash
python app.py
```

Server berjalan di `http://localhost:5000`.

---

## Menggunakan Web UI

Aplikasi menyediakan beberapa halaman:

- **Beranda**: `GET /` atau `GET /beranda`
- **Klasifikasi**: `GET /clasify`
  - Umumnya berisi fitur upload gambar dan/atau kamera (tergantung implementasi front-end).
- **Pencarian metadata**: `GET /search`

Jika UI tidak menampilkan hasil, buka DevTools browser dan cek response API (lihat bagian API).

---

## Menggunakan API

Semua response API menggunakan JSON dan biasanya mengembalikan key `success`.

### 1) Upload gambar dari file

**Endpoint**: `POST /upload`

**Content-Type**: `multipart/form-data`

**Field**:
- `file`: file gambar (`.png`, `.jpg`, `.jpeg`, `.bmp`)

**Contoh (curl)**:

```bash
curl -X POST http://localhost:5000/upload \
  -F "file=@path/to/flower.jpg"
```

**Response (sukses, bunga terdeteksi)** (ringkas):

```json
{
  "success": true,
  "is_flower": true,
  "mode": "upload",
  "predicted_name": "...",
  "confidence": 0.93,
  "confidence_percent": "93.00%",
  "image_data": "data:image/jpeg;base64,...",
  "metadata": {
    "id": "...",
    "name": "...",
    "scientific_name": "...",
    "physical_characteristics": "...",
    "habitat": "...",
    "benefits_or_meaning": "...",
    "dynamic_description": "..."
  },
  "quality_info": {
    "is_valid": true,
    "reason": "OK",
    "brightness": 123.4,
    "blur_score": 55.6
  }
}
```

**Response (kualitas gambar buruk)**: `success=true` tetapi `is_flower=false` + `warning`.

**Response (bukan bunga / confidence rendah)**: `success=true` tetapi `is_flower=false` + `warning`.

**Response (gagal)**:

```json
{ "success": false, "error": "..." }
```

Catatan:
- Batas ukuran upload dikonfigurasi di server (16MB).

---

### 2) Capture dari kamera (base64)

**Endpoint**: `POST /capture`

**Content-Type**: `application/json`

**Body**:

```json
{ "image": "data:image/jpeg;base64,..." }
```

**Contoh (curl)**:

```bash
curl -X POST http://localhost:5000/capture \
  -H "Content-Type: application/json" \
  -d "{\"image\":\"data:image/jpeg;base64,AAAA...\"}"
```

Response mirip dengan `/upload`, namun `mode` bernilai `camera`.

---

### 3) Search metadata bunga

**Endpoint**: `POST /api/search`

**Content-Type**: `application/json`

**Body**:

```json
{ "query": "rose" }
```

**Contoh (curl)**:

```bash
curl -X POST http://localhost:5000/api/search \
  -H "Content-Type: application/json" \
  -d "{\"query\":\"rose\"}"
```

**Response (sukses)**:

```json
{
  "success": true,
  "count": 2,
  "results": [
    {
      "id": "1",
      "name": "...",
      "scientific_name": "...",
      "physical_characteristics": "...",
      "habitat": "...",
      "benefits_or_meaning": "..."
    }
  ]
}
```

**Response (query kosong)**:

```json
{ "success": false, "error": "Query kosong" }
```

---

## File Model & Metadata

Aplikasi membaca file berikut di `models/`:

- `flower_classification_model_MobileNetV2.keras` — model inference.
- `flower_metadata.json` — metadata untuk tiap kelas.
- `cat_to_name.json` — mapping nama bunga.
- `class_indices.json` — mapping index output model ke label class (disarankan ada).

Jika `class_indices.json` tidak ada, server mencoba membuat mapping dari folder `../dataset/train` (jika ada), atau dari key `cat_to_name.json`.

---

## Troubleshooting

- **Error saat install TensorFlow**: pastikan versi Python Anda kompatibel dengan TensorFlow yang dipilih. Jika perlu, gunakan Python versi yang umum kompatibel (seringnya 3.10/3.11) dan upgrade `pip`.
- **`cv2` tidak ditemukan**: pastikan `opencv-python` ter-install dari `requirements.txt`.
- **Prediksi selalu "Unknown" / confidence 0**: cek `quality_info` pada response; bisa jadi gambar terlalu gelap/terang/blur.
- **Model tidak terbaca**: pastikan file `models/flower_classification_model_MobileNetV2.keras` ada dan path relatif tidak berubah.

---

## Catatan Keamanan

- Jangan aktifkan `debug=True` saat di-deploy.
- Batasi ukuran upload dan pertimbangkan validasi tambahan jika aplikasi diakses publik.
