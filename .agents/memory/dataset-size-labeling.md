---
name: Dataset size labeling
description: In Version 2, the Size feature was removed from dataset.csv and all model schemas.
---

In Version 2 of the Tacloban City Calamansi Harvest Study, the `Size` feature (1=Small, 2=Medium, 3=Large) was removed from the dataset and model training:
- **Why removed:** Fruit size buckets were derived directly from fruit weight, introducing artificial multicollinearity without improving accuracy, while requiring manual fruit sorting. In Version 2, predictions use purely measured fruit weight (`Weight` -> `Juice`), allowing batch calculations directly from scale weights.
- **Dataset schema:** `dataset.csv` contains only two columns: `Weight` and `Juice`.