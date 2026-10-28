# Calamansi Yield Predictor

An agricultural yield prediction web application built with React, TypeScript, and Tailwind CSS. The dataset contains calamansi weight and measured juice-yield records.

## Overview

The prediction compares four weight-only models: **Simple Linear Regression (SLR)**, **Polynomial Regression (Degree 2)**, **Support Vector Regression (RBF Kernel)**, and **Polynomial (d=2) + ln(W) & L2 Ridge**. The Poly+ model is the proposed champion model (82.44% R², 0.4874 mL MAE). Model parameters and validation metrics are trained from `dataset.csv`; the app uses those same generated parameters for predictions.

Training and evaluation rules:
- `Size` is excluded; the system operates strictly on fruit weight (`W`).
- Stratified 5-fold cross-validation partitions verified clean harvest records (N = 1,478) across weight strata with clerical data-entry errors removed.
- All four models are evaluated under the identical stratified validation protocol.
- Primary Poly+ model's Ridge strength is selected via nested cross-validation (selected α = 0.001).
- Fixed parameters for RBF SVR: `C = 1`, `ε = 0.1`, and `γ = 0.05` with dual SMO solver evaluating 1,283 support vectors.

## Key Features

- **Batch Yield Estimator**: Interactive calculator supporting kilograms (`kg`) and grams (`g`) with quick select presets.
- **Model Evaluation**: Four weight-only models compared on the same stratified folds, with R², MAE, RMSE, MAPE, and generated formulas.
- **Research Analytics**: Dataset sample counts, weight-only model formulas, and training settings.
- **Harvest History**: Detailed log of past calculations with instant search, multi-device cloud sync, and CSV data export with formula injection protection.
- **Admin Console**: User account management (create, suspend/activate, change role, reset password), prediction audit logs, and Supabase cloud database settings.
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