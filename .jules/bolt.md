# Bolt's Journal

## 2024-05-22 - [Example Entry]
**Learning:** This is an example entry.
**Action:** Always check for this file first.

## 2024-05-23 - Conditional Animation Wrappers
**Learning:** List items that only need entrance animations (like `TweenAnimationBuilder`) should conditionally bypass the animation wrapper once they are "shown". Wrapping every item in a builder, even with `duration: zero`, adds unnecessary depth and machinery overhead.
**Action:** Use `if (!shouldAnimate) return content;` pattern to return static content directly.
