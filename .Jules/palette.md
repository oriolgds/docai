## 2025-05-23 - [Missing Tooltip Implementation]
**Learning:** Even required parameters in widgets can be ignored in the build method, leading to accessibility gaps. `_ActionButton` required `tooltip` but never used it.
**Action:** Always check that passed parameters are actually used in the widget tree, especially for semantic properties like tooltips.
