## 2024-05-22 - Caching Expensive Operations in Build Loops
**Learning:** `ValueListenableBuilder` triggers frequently (e.g., every keystroke). Avoid calculating constant values (like `DateTime.now()` checks) inside the builder. Cache them in `initState`.
**Action:** Cache derived state that doesn't depend on the listenable value outside the builder.
