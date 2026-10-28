---
name: RBF SVR optimization
description: Numerical bound handling required for the custom epsilon-SVR dual-coordinate solver.
---

Treat dual coefficients within a small tolerance of the `±C` bounds as already at their limits when choosing feasible coordinate directions. Floating-point values can appear just inside a bound while leaving only a negligible update, causing the solver to repeatedly select a blocked pair and report a stall.

**Why:** Full-dataset grouped cross-validation exposed this edge case even though a smaller synthetic fit converged.

**How to apply:** Preserve the explicit bound tolerance in feasibility checks and validate optimizer convergence on the complete training dataset after changes.
