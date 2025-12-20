## 2024-05-23 - Micro-optimizing Animation Loops
**Learning:** High-frequency animations (like typing indicators) implemented with `AnimatedBuilder` inside `List.generate` can cause significant widget rebuild overhead (e.g., 3 rebuilds per frame).
**Action:** Replace widget-based animations with `CustomPaint` and a single animation controller for CPU/GPU efficiency when the visual complexity is low (simple shapes).
