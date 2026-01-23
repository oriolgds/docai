## 2024-05-22 - Flutter Widget Optimization
**Learning:** `ValueListenableBuilder` triggers frequently (e.g., every keystroke). Avoid expensive computations (like `DateTime.now()` or complex logic) inside its builder.
**Action:** Move invariant calculations to `initState` or use `late final` variables to cache results that don't change during the widget's lifecycle.
