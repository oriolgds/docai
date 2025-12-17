## 2025-02-18 - Input Field Focus Indicators
**Learning:** Custom input containers using `Container` decoration often miss the built-in focus state handling of `InputDecoration`. This leads to poor accessibility as keyboard/screen reader users don't see when the field is active.
**Action:** Always prefer `InputDecoration` properties (`focusedBorder`, `enabledBorder`, `filled`) over wrapping `TextField` in a decorated `Container`.

## 2025-02-19 - Localized Icon-Only Button Tooltips
**Learning:** Icon-only buttons rely heavily on tooltips for accessibility and understanding. Hardcoding these strings (even simple ones like "Menu") creates a barrier for non-English speakers.
**Action:** Always define `tooltip` strings in localization files (`.arb`) and use `AppLocalizations` to retrieve them, ensuring all users have equal access to button descriptions.
