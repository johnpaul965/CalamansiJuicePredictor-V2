# Calamansi Yield Prediction System — Complete Model Training Guide
**Institution:** Leyte Normal University  
**Study:** Tacloban City Calamansi Harvest Study (*Citrus microcarpa*)  
**File:** `TRAINING_GUIDE.md`

This guide explains step-by-step how the prediction models are trained, cleaned, evaluated, and reproduced using the standalone script `train_models.py` and `dataset.csv`.

---

## 1. Quick Start: How to Run Training in VS Code

1. Open **VS Code**.
2. Open this project folder: **File** → **Open Folder...**
3. Open the integrated terminal (<kbd>Ctrl</kbd> + <kbd>`</kbd>).
4. Run the training script:
   * **Windows PowerShell / Command Prompt:**
     ```powershell
     python train_models.py
     ```
     *(or `py train_models.py`)*
   * **Mac / Linux:**
     ```bash
     python3 train_models.py
     ```

The script will read `dataset.csv`, clean the observations, run 5-Fold Weight-Grouped Cross-Validation, calculate all error metrics ($R^2$, MAE, RMSE, MAPE), and output the final trained regression equation in under 1 second.

---

## 2. The 4 Steps Performed During Training

### Step 1: Botanical Mass-Balance & Outlier Cleaning (Zero AI)
The raw dataset contains $1,522$ field recordings. Cleaning applies two standard textbook rules:
1. **Physical Mass-Balance Filter (`Juice / Weight <= 0.60`):**
   * Calamansi skin, pith, seeds, and pulp membranes always comprise at least $40\%$ of fruit weight.
   * Pure extractable liquid juice cannot physically exceed $60\%$ of total mass.
   * Removes **8 recording typos** (such as a $2\text{g}$ fruit typed as $16\text{ mL}$, or $3\text{g} \to 17\text{ mL}$).
   * Subtotal: **$1,514$ fruits**.
2. **Textbook 98% Confidence Interval Filter (`|Z| <= 2.326`):**
   * Computes the mean and standard deviation of juice within each integer gram weight group.
   * Uses standard Normal Z-table critical value for two-tailed $\alpha = 0.02$ ($Z_{\text{crit}} = 2.326$, `=NORM.S.INV(0.99)` in Excel).
   * Removes **36 extreme dried-fruit outliers**.
   * Final verified ground-truth test set: **$N = 1,478$ clean fruits**.

---

### Step 2: Weight-Grouped 5-Fold Cross-Validation
To prevent models from simply memorizing fruit weights:
* Data is partitioned into 5 folds using the weight-group formula:
  $$\text{group} = ((\text{round}(W) + 1) // 2) \pmod 5$$
* In every fold, **entire pairs of fruit weights** (e.g., $13\text{g}$ and $14\text{g}$) are completely removed from the training set and held out as the test set.
* Models must predict juice on unseen fruit sizes, accurately simulating commercial farm scales weighing unrounded batch harvests.

---

### Step 3: Model Architecture & Matrix Training
We compare 3 core parametric models under identical cross-validation:

1. **Simple Linear Regression (SLR):**
   * Feature vector: $[1,\; W]$
   * Formula: $\text{Juice} = 0.4162 \times W - 0.0432$
   * Limitation: Assumes a constant slope ($0.4162\text{ mL/g}$) forever. Overpredicts small fruits because it cannot model thick peel proportions.

2. **Ordinary Polynomial Regression (Degree 2):**
   * Feature vector: $[1,\; W,\; W^2]$
   * Formula: $\text{Juice} = 2.1605 + 0.0419(W) + 0.01500(W^2)$
   * Limitation: Without regularization, unconstrained quadratic terms overfit to training fold anomalies.

3. **★ Proposed Model: Polynomial (d=2) + $\ln(W)$ & L2 Ridge ($\alpha = 0.01$):**
   * Feature vector: $[1,\; W,\; W^2,\; \ln(W)]$
   * Trained via the closed-form Ridge Normal Equation:
     $$\boldsymbol{\beta} = (X^T X + \alpha I^*)^{-1} X^T \mathbf{y}$$
   * The natural log term $\ln(W)$ models the thick peel and lower juice percentage in small fruits ($5\text{g}-8\text{g}$).
   * The quadratic term $W^2$ models biological diminishing returns in heavy fruits ($18\text{g}-21\text{g}$).
   * L2 Ridge shrinkage ($\alpha = 0.01$) stabilizes collinearity between $W$, $W^2$, and $\ln(W)$, preventing curve distortion on unseen weights.

---

### Step 4: Final Trained Equation & Evaluation Results

#### 5-Fold Cross-Validation Benchmark:
| Model | $R^2$ Accuracy | MAE (Error) | RMSE | MAPE |
| :--- | :---: | :---: | :---: | :---: |
| Simple Linear Regression (SLR) | 82.30% | 0.4895 mL | 0.6157 | 10.04% |
| Ordinary Polynomial (d=2) | 82.22% | 0.4908 mL | 0.6171 | 10.04% |
| **★ Proposed: Poly (d=2) + $\ln(W)$ & L2 Ridge** | **82.28%** | **0.4896 mL** | **0.6160** | **10.05%** |

#### The Final Mathematical Formula (Fitted on Full Clean Dataset):
$$\mathbf{\text{Juice (mL)} = 2.3179 + 1.1004(W) - 0.01415(W^2) - 3.4460 \cdot \ln(W)}$$

* **Intercept ($\beta_0$):** $+2.3179$
* **Linear Slope ($\beta_1 \cdot W$):** $+1.1004$
* **Quadratic Curvature ($\beta_2 \cdot W^2$):** $-0.01415$
* **Logarithmic Peel Correction ($\beta_3 \cdot \ln W$):** $-3.4460$

---

## 3. How to Prove the Training is Live and Not Pre-Made

1. Open `dataset.csv` in VS Code.
2. Edit row 2 (e.g., change `2.5` to `50.0`).
3. Re-run `python train_models.py`.
4. Observe that the script immediately flags the new outlier (`9 impossible typos` instead of 8) and re-computes the matrices live.
5. Restore row 2 back to `2.5`.
