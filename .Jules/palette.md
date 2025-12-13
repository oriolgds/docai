## 2025-05-23 - [Missing Tooltip Implementation]
**Learning:** Even required parameters in widgets can be ignored in the build method, leading to accessibility gaps. `_ActionButton` required `tooltip` but never used it.
**Action:** Always check that passed parameters are actually used in the widget tree, especially for semantic properties like tooltips.

## 2025-05-24 - [Primary Action Button Accessibility]
**Learning:** Primary action buttons like "Send" and "Voice Input" lacked tooltips, which are critical for screen reader users and desktop users to understand the icon's function.
**Action:** Always verify that icon-only buttons have a `tooltip` property defined, relying on `AppLocalizations` for internationalization.
