## 2024-05-30 - [List Iteration Performance]
**Learning:** Found O(N^2) complexity in `PresetSelectorSheet` and `ModelSelectorSheet` where `indexOf(item)` was called inside a `map` loop to calculate staggered animation delays.
**Action:** Use `.asMap().entries.map(...)` to access the index directly during iteration (O(1) access), reducing the overall complexity to O(N).
