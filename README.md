# SkinCancel - Skin Cancer Detection App

An AI-powered web application that analyzes dermoscopy images and classifies
skin lesions as **Benign** or **Malignant** using a fine-tuned VGG16 deep
learning model. It ships with a custom, hand-built **dark-themed UI** (Tailwind
CSS) and stores every analysis against a patient record.

---
## Demo video and screenshoots 
[please consult this link](https://drive.google.com/drive/folders/1QUSUIYY4xY-MAzHwywwpmHuwpTGcdYmq?usp=sharing)
## Features

- **Doctor login** — session-based authentication (default `admin` / `admin123`).
- **Dashboard** — at-a-glance stats: total patients, malignant cases, benign
  cases, and the five most recent analyses.
- **Image upload** — submit a dermoscopy image (PNG / JPG / JPEG, up to 16 MB)
  together with the patient's name and age.
- **AI diagnosis** — the VGG16 model returns a Benign/Malignant label with a
  confidence score, saved to the patient's record.
- **Patient history** — a searchable registry of all past analyses.
- **PDF export** — download a formatted diagnostic report per patient.

> Features are kept accurate to what `app.py` actually implements.

---

## Tech Stack

| Layer      | Technology                                   |
| ---------- | -------------------------------------------- |
| Backend    | Python + Flask                               |
| AI Model   | VGG16 (transfer learning + fine-tuning)      |
| Database   | MySQL                                         |
| Frontend   | HTML + Tailwind CSS (custom dark theme)      |
| Training   | Google Colab + TensorFlow                    |

---

## Model

- **Architecture:** VGG16 (ImageNet weights) with blocks 4–5 fine-tuned, a
  global-average-pooling head, a 256-unit dense layer, dropout, and a single
  **sigmoid** output neuron.
- **Task:** binary classification — Benign vs. Malignant.
- **Input:** RGB images resized to **224 × 224**, rescaled by `1/255`.
- **Output:** one sigmoid value in `[0, 1]`; `> 0.5` is reported as
  **Malignant**, otherwise **Benign**. The displayed confidence is the
  distance of the score from the decision boundary.

> **The trained model file is NOT included in this repository.** `model/vgg16_skin_cancer.h5`
> is gitignored (it exceeds GitHub's 100 MB limit) and must be trained or
> provided separately, then placed at `model/vgg16_skin_cancer.h5`. It must be
> saved in a **Keras 2 / TensorFlow 2.15-compatible HDF5** format to match
> `requirements.txt`.

---

## Project Structure

```
Skin_Cancel/
├── app.py                
├── config.py              
├── requirements.txt       
├── database/
│   └── schema.sql         # CREATE TABLE statements + admin seed (see below)
├── model/
│   └── vgg16_skin_cancer.h5   # NOT in repo — add your trained model here
├── static/
│   └── uploads/           
└── templates/             
    ├── base.html
    ├── login.html
    ├── dashboard.html
    ├── predict.html
    ├── result.html
    └── patients.html
```

---

## How to Run Locally

### 1. Clone

```bash
git clone https://github.com/Firas-Bennani/Skin_Cancel.git
cd Skin_Cancel
```

### 2. Create the Python environment

The pinned `tensorflow==2.15.0` requires Python 3.9–3.11. Use a Python 3.10 env:

```bash
conda create -n skincancel python=3.10 -y
conda activate skincancel
pip install -r requirements.txt
```

### 3. Set up MySQL

`config.py` connects to: host `localhost`, user `root`, **empty password**,
database `skin_cancer_db` (port 3306).

The quickest option is Docker:

```bash
docker run --name skincancel-mysql \
  -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
  -e MYSQL_DATABASE=skin_cancer_db \
  -p 3306:3306 -d mysql:8
```

### 4. Create the tables and the default login

The repository's `database/schema.sql` is now populated with the schema and
seed below. Load it once:

```bash
# via the running container:
docker exec -i skincancel-mysql mysql -uroot < database/schema.sql
# or with a local mysql client:
mysql -uroot < database/schema.sql
```

For reference, the SQL it runs:

```sql
CREATE DATABASE IF NOT EXISTS skin_cancer_db;
USE skin_cancer_db;

CREATE TABLE IF NOT EXISTS users (
    id       INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50)  NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS patients (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    age         INT          NOT NULL,
    diagnosis   VARCHAR(50),
    short_code  VARCHAR(10),
    risk_level  VARCHAR(20),
    confidence  FLOAT,
    image_path  VARCHAR(255),
    created_by  VARCHAR(50),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Default login: admin / admin123
INSERT INTO users (username, password)
SELECT 'admin', 'admin123'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'admin');
```

### 5. Add the trained model

Place your trained weights at:

```
model/vgg16_skin_cancer.h5
```

(See the **Model** section — it must be a Keras 2 / TF 2.15-compatible `.h5`.)

### 6. Run

```bash
python app.py
```

Open <http://localhost:5000> and log in with **admin / admin123**.

---

## Disclaimer

This application is **AI-assisted and is not a substitute for professional
medical judgment**. Predictions are produced by a model trained on a custom
dataset and may be inaccurate. Always consult a certified dermatologist for any
real diagnosis. This project is intended for educational and research purposes
only.
