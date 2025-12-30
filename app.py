from __future__ import annotations

import os
from pathlib import Path

from flask import Flask, render_template, request
from werkzeug.utils import secure_filename

APP_ROOT = Path(__file__).resolve().parent
UPLOAD_DIR = APP_ROOT / "uploads"
UPLOAD_DIR.mkdir(exist_ok=True)

ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg", "webp"}

app = Flask(__name__)


def _allowed_file(filename: str) -> bool:
    if not filename or "." not in filename:
        return False
    ext = filename.rsplit(".", 1)[1].lower()
    return ext in ALLOWED_EXTENSIONS


def _predict_placeholder(_: Path) -> tuple[str, str]:
    return (
        "(placeholder) belum ada model",
        "Tambahkan model di folder models/ dan implementasikan loader di app.py.",
    )


@app.get("/")
def index():
    return render_template("index.html", error=None)


@app.post("/predict")
def predict():
    if "image" not in request.files:
        return render_template("index.html", error="File tidak ditemukan."), 400

    file = request.files["image"]
    if file.filename is None or file.filename.strip() == "":
        return render_template("index.html", error="Nama file kosong."), 400

    filename = secure_filename(file.filename)
    if not _allowed_file(filename):
        return render_template(
            "index.html",
            error="Format file tidak didukung. Pakai: png/jpg/jpeg/webp",
        ), 400

    save_path = UPLOAD_DIR / filename
    file.save(save_path)

    label, note = _predict_placeholder(save_path)

    try:
        os.remove(save_path)
    except OSError:
        pass

    return render_template("result.html", filename=filename, label=label, note=note)


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000, debug=True)
