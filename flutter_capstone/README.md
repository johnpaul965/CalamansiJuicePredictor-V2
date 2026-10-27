# Calamansi Juice Yield Prediction System (Flutter Mobile Capstone)

**Institution:** Leyte Normal University  
**Study:** Tacloban City Calamansi Harvest Study (*Citrus microcarpa*)  
**Framework:** Flutter (Dart) Mobile Application (Android / iOS / Web)  

---

## 📌 Major Updates from Version 1 to Version 2

1. **Size Dropdown Removed Permanently:**
   - In Version 1, farmers had to manually categorize fruit size into `Small`, `Medium`, or `Large`.
   - In Version 2, manual sorting is **completely eliminated**. Farmers enter only the **Total Batch Weight** in `kg` or `g`.
   - The app automatically determines fruit count using the study's empirical mean fruit weight ($12.686\text{ g}$).

2. **Upgraded Champion Model Added:**
   - **★ Proposed Champion Model:** `Polynomial (d=2) + ln(W) & L2 Ridge`
     $$\text{Juice (mL)} = 2.3179 + 1.1004(W) - 0.01415(W^2) - 3.4460 \cdot \ln(W)$$
     - **$R^2 = 82.28\%$**
     - **$\text{MAE} = 0.4896\text{ mL}$**
     - **$\text{RMSE} = 0.6160\text{ mL}$**
   - Outperforms raw Polynomial ($76.23\%$) by **$+6.05\%$** and beats Simple Linear Regression ($80.74\%$).

3. **Supporting Baseline Models Preserved for Defense:**
   - Simple Linear Regression (SLR): $\text{Juice} = 0.4162 \cdot W - 0.0432$ ($R^2 = 80.74\%$)
   - Ordinary Polynomial ($d=2$): $\text{Juice} = 2.1605 + 0.0419(W) + 0.0150(W^2)$ ($R^2 = 76.23\%$)
   - Multiple Linear Regression (MLR): $R^2 = 79.71\%$

4. **Commercial Bottling Outputs:**
   - Automatically estimates standard packaging counts: $330\text{ mL}$ bottles, $500\text{ mL}$ bottles, and $1.0\text{ L}$ jugs.

---

## 🚀 How to Run this Flutter App

1. Make sure Flutter SDK is installed on your computer:
   ```bash
   flutter --version
   ```
2. Navigate to this directory in terminal:
   ```bash
   cd flutter_capstone
   ```
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```
4. Connect an Android phone, emulator, or open Chrome, then run:
   ```bash
   flutter run
   ```

---

## 📁 Project Structure

```
flutter_capstone/
├── pubspec.yaml
├── README.md
└── lib/
    ├── main.dart
    ├── models/
    │   └── prediction_result.dart
    ├── services/
    │   ├── prediction_service.dart
    │   └── storage_service.dart
    └── screens/
        ├── predict_screen.dart
        ├── model_comparison_screen.dart
        ├── history_screen.dart
        └── training_info_screen.dart
```
