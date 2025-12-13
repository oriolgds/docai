## 2024-05-22 - [Flutter Text Input Rebuilds]
**Learning:** Found `TextEditingController` listener triggering global `setState` on every keystroke in `NativeChatScreen`. This causes full screen rebuilds including complex Markdown rendering and BackdropFilters.
**Action:** Use `ValueListenableBuilder` to isolate updates dependent on text changes (e.g., button toggling) instead of rebuilding the entire screen.
