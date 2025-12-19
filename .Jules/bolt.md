## 2024-05-22 - [Flutter Text Input Rebuilds]
**Learning:** Found `TextEditingController` listener triggering global `setState` on every keystroke in `NativeChatScreen`. This causes full screen rebuilds including complex Markdown rendering and BackdropFilters.
**Action:** Use `ValueListenableBuilder` to isolate updates dependent on text changes (e.g., button toggling) instead of rebuilding the entire screen.

## 2024-05-24 - [Scroll Listener Performance]
**Learning:** Found `setState` being called on every scroll event in `NativeChatScreen` to update `_isNearBottom`, a variable not used in the `build()` method. This triggers unnecessary high-frequency rebuilds of the entire screen during scrolling.
**Action:** Verify if state variables are actually used in `build()` before wrapping updates in `setState`. Remove `setState` for logic-only state updates.

## 2025-12-15 - [Animation Controller Resource Usage]
**Learning:** Discovered `SnowfallAnimation` was running its `AnimationController` loop continuously even when invisible/disabled, consuming CPU resources unnecessarily.
**Action:** Always manage `AnimationController` state (start/stop) based on visibility or enabled state. Use `didUpdateWidget` to react to property changes and stop animations when not needed.

## 2025-05-27 - [Markdown Parsing Bottleneck]
**Learning:** `MarkdownBody` in `NativeChatScreen` was being re-parsed and rebuilt on every state update (e.g., typing) and scroll event, causing jank. `ListView.builder` rebuilds items frequently, and `MarkdownBody` parsing is CPU intensive.
**Action:** Implemented `CachedMarkdownBody` to cache the widget instance and skip re-parsing when content hasn't changed. Also increased `ListView.cacheExtent` to keep more items alive off-screen.

## 2025-05-28 - [BackdropFilter Performance]
**Learning:** `BackdropFilter` was used on `_buildSideNav` and `_buildHeader` over a solid `Scaffold` background. This forces an expensive `saveLayer` and blur pass for no visual benefit (blurring a solid color is still a solid color).
**Action:** Remove `BackdropFilter` (and wrapping `ClipRect`) when the background is known to be solid/static. Use semi-transparent `Container` colors instead.
