# Calamansi Yield Predictor

An empirical agricultural yield prediction web application rewritten in React, TypeScript, and Tailwind CSS based on the calamansi harvest research study conducted by Leyte Normal University in Tacloban City, Philippines.

## Overview

The application accurately predicts pure calamansi juice extraction yield using three trained regression architectures evaluated on 1,522 real fruit harvest samples:
1. **Simple Linear Regression (SLR)**: Baseline model based on batch weight (`Juice = 0.4569 × Weight - 0.6080`, R² = 0.7099)
2. **Multiple Linear Regression (MLR)**: Evaluates batch weight and size grade (`Juice = 0.4580 × Weight - 0.0053 × Size - 0.6108`, R² = 0.7100)
3. **Polynomial Regression (Degree 2)**: Best-performing non-linear architecture (`Juice = -0.5480 + 0.4357(W) + 0.0865(S) - 0.0031(W²) + 0.0474(W·S) - 0.1641(S²)`, R² = 0.7102, MAE = 0.5279 ml)

## Key Features

- **Batch Yield Estimator**: Interactive calculator supporting kilograms (`kg`) and grams (`g`) with quick select presets and empirical size grading.
- **Model Comparison Suite**: Side-by-side evaluation of all three models with accuracy metrics (R², MAE, RMSE, MSE, MAPE) and commercial packaging estimates (330ml, 500ml, 1.0L bottles).
- **Research Analytics**: Dataset breakdown of 1,522 samples across Small, Medium, and Large size categories, complete formulas, and learned coefficients.
- **Harvest History**: Detailed log of past calculations with instant search and clear capabilities.
- **Admin Console**: User account management (create, suspend/activate, change role, reset password), prediction audit logs, and CSV data export.
- **Demo Accounts**: Quick sign-in buttons for `farmer_juan` (User) and `admin` (Administrator).

## Tech Stack

- **Framework**: React 19 + TypeScript
- **Bundler**: Vite
- **Styling**: Tailwind CSS
- **Icons**: Lucide React
- **Storage**: In-memory and browser localStorage persistence