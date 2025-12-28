# Bolt's Journal

## 2024-05-22 - Flutter Widget Caching
**Learning:** `DateTime.now()` in `ValueListenableBuilder` triggers unnecessary recalculations on every keystroke.
**Action:** Move static state checks (like seasonal features) to `initState` or lazy getters to avoid main-thread work during rapid user interactions.
