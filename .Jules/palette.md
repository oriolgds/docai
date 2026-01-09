## 2024-05-23 - Missing Auto-Save Feedback
**Learning:** Users lack confidence when auto-save operations are silent. Even if the backend works perfectly, the UI must provide confirmation.
**Action:** Always include a visual indicator (spinner, checkmark) for background save operations, even for small preferences forms.

## 2024-05-23 - Timer Race Conditions in UI Feedback
**Learning:** Using `Future.delayed` for UI resets (like hiding a success message) can lead to race conditions if the action is triggered repeatedly.
**Action:** Always use a cancellable `Timer` object stored in the state, and cancel it before starting a new operation or disposing the widget.
