-- SkinCancel — database schema
-- Matches the queries in app.py (config.py -> DB_NAME = "skin_cancer_db").
-- Run this once against a fresh MySQL instance to recreate the database,
-- tables, and the default admin login.

CREATE DATABASE IF NOT EXISTS skin_cancer_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE skin_cancer_db;

-- Clinician accounts.
-- login() reads: SELECT * FROM users WHERE username = %s AND password = %s
CREATE TABLE IF NOT EXISTS users (
    id       INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50)  NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);

-- One row per analysis.
-- predict() inserts: name, age, diagnosis, short_code, risk_level,
-- confidence, image_path, created_by. dashboard()/patients() read these
-- plus id and created_at.
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
-- (Stored as plain text because app.py compares the password column directly.)
INSERT INTO users (username, password)
SELECT 'admin', 'admin123'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'admin');
