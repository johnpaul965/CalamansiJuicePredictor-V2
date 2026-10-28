# Calamansi Yield Predictor

An agricultural yield prediction web application built with React, TypeScript, and Tailwind CSS. The dataset contains calamansi weight and measured juice-yield records.

## Overview

The prediction compares four weight-only models: **Simple Linear Regression (SLR)**, **Polynomial Regression (Degree 2)**, **Support Vector Regression (RBF Kernel)**, and **Polynomial (d=2) + ln(W) & L2 Ridge**. The Poly+ pipeline is the top-performing model (`82.28%` R², `0.4897 mL` MAE). Model parameters and validation metrics are trained directly from `dataset.csv`; the app uses those same generated parameters for predictions.

Training and evaluation rules:
- `Size` is excluded; the system operates strictly on fruit weight (`W`).
- 2-gram weight-grouped 5-fold cross-validation (`((floor(W) + 1) // 2) % 5`) evaluates held-out fruit weight groups against verified clean ground-truth harvest records (`N = 1,478`, clerical data-entry errors removed).
- The Proposed Poly+ model runs as an end-to-end pipeline with automated in-fold training sanitization (`Juice/Weight ≤ 0.60` and within-weight `|Z| ≤ 2.326`) and standardized L2 Ridge regularization (`α = 0.01`), benchmarked against untuned off-the-shelf baselines.
- Fixed baseline parameters for RBF SVR: `C = 1`, `ε = 0.1`, and `γ = 0.05` with dual SMO solver (`1,283` support vectors on the final clean fit).
- The champion flag (`isChampion`) is assigned dynamically to whichever model achieves the highest cross-validation `R²` (lowest `MAE` tie-breaker).

## Key Features

- **Batch & Single-Fruit Yield Estimator**: Interactive calculator supporting kilograms (`kg`) and grams (`g`) with quick select presets.
- **Model Evaluation**: Four weight-only models evaluated via weight-grouped 5-fold cross-validation, reporting `R²`, `MAE`, `RMSE`, `MAPE`, and generated formulas.
- **Research Analytics**: Dataset sample counts, weight-only model formulas, and training settings.
- **Harvest History**: Detailed log of past calculations with instant search, multi-device cloud sync, and CSV data export with formula injection protection.
- **Admin Console**: User account management (create, suspend/activate, change role, reset password), prediction audit logs, and Research Analytics Portal.
- **Dual Persistence Architecture**: Supabase PostgreSQL cloud sync for multi-device live deployment, with automatic seamless offline localStorage fallback.
- **Demo Accounts**: Instant sign-in buttons for `farmer_juan` (User) and `admin` (Administrator).

## Tech Stack

- **Framework**: React 19 + TypeScript
- **Bundler**: Vite
- **Styling**: Tailwind CSS
- **Icons**: Lucide React
- **Cloud Database**: Supabase (PostgreSQL) + LocalStorage offline fallback

## Model training

Run `npm run train:model` to train the models and regenerate the metric files from the root `dataset.csv`. `npm run dev` and `npm run build` run training automatically first. Run `npm run test:model` for the training-pipeline checks.