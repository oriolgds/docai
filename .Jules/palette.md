## 2025-02-18 - Input Field Focus Indicators
**Learning:** Custom input containers using `Container` decoration often miss the built-in focus state handling of `InputDecoration`. This leads to poor accessibility as keyboard/screen reader users don't see when the field is active.
**Action:** Always prefer `InputDecoration` properties (`focusedBorder`, `enabledBorder`, `filled`) over wrapping `TextField` in a decorated `Container`.
