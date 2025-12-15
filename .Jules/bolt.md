## 2024-05-22 - [Flutter Text Input Rebuilds]
**Learning:** Found `TextEditingController` listener triggering global `setState` on every keystroke in `NativeChatScreen`. This causes full screen rebuilds including complex Markdown rendering and BackdropFilters.
**Action:** Use `ValueListenableBuilder` to isolate updates dependent on text changes (e.g., button toggling) instead of rebuilding the entire screen.

## 2024-05-24 - [Scroll Listener Performance]
**Learning:** Found `setState` being called on every scroll event in `NativeChatScreen` to update `_isNearBottom`, a variable not used in the `build()` method. This triggers unnecessary high-frequency rebuilds of the entire screen during scrolling.
**Action:** Verify if state variables are actually used in `build()` before wrapping updates in `setState`. Remove `setState` for logic-only state updates.

## 2025-12-15 - [Animation Controller Resource Usage]
**Learning:** Discovered `SnowfallAnimation` was running its `AnimationController` loop continuously even when invisible/disabled, consuming CPU resources unnecessarily.
**Action:** Always manage `AnimationController` state (start/stop) based on visibility or enabled state. Use `didUpdateWidget` to react to property changes and stop animations when not needed.
