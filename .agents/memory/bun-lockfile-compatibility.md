---
name: Bun lockfile compatibility
description: Replit-managed Bun 1.3 did not understand this project's imported Bun lockfile format.
---

The imported `bun.lock` uses lockfile version 2, which the managed Bun 1.3 installer could not parse. It proceeded without the lockfile and changed dependency versions, the lockfile, and `.replit` module configuration.

**Why:** The installer reported success despite explicitly warning that it ignored the lockfile, so an install can silently leave the project on a different dependency set.

**How to apply:** Check the lockfile format against the package-manager version before installing. After any install, verify `package.json`, the lockfile, and `.replit`; restore unrelated changes when the installer cannot honor the imported lockfile.
