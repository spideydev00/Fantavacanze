---
name: flutter-errors
description: Diagnoses and fixes common Flutter errors. Use when encountering layout errors (RenderFlex overflow, unbounded constraints, RenderBox not laid out), scroll errors, or setState-during-build errors.
---

# Flutter Errors Skill

This skill provides solutions for the most common Flutter runtime and layout errors.

## The mental model

Flutter layout is a single rule: **Constraints go down. Sizes go up. Parent sets
position.** Almost every layout error is this negotiation failing — either a parent hands
down *unbounded* constraints (infinite height/width) or a child demands *more* than the
parent allows. Fix the constraint, not the symptom. To design layouts that avoid these in
the first place, see [[flutter-responsive-ui]].

## Diagnostic workflow

1. Run in debug and read the **first** exception in the console.
2. Identify the *primary* error and ignore cascading ones. In particular
   **`RenderBox was not laid out` is almost never the real bug** — it's a side effect.
   Scroll *up* the stack trace to the real cause (usually an unbounded height/width).
3. Map the error signature → fix (table below), apply, hot reload.
4. Re-check: red error screen gone, no yellow/black overflow stripes. If a new error
   appears, repeat.

| Error signature | Real cause | Fix |
|---|---|---|
| `RenderFlex overflowed by X px` | Child of `Row`/`Column` bigger than allowed | wrap child in `Expanded` (force fit) or `Flexible` (allow smaller); `Text` → add `overflow: TextOverflow.ellipsis` |
| `Vertical viewport was given unbounded height` | scrollable inside an unbounded `Column` | wrap scrollable in `Expanded`, or give a `SizedBox` height; or use `shrinkWrap: true` for small lists |
| `InputDecorator ... cannot have an unbounded width` | `TextField` in a `Row` with no width | wrap field in `Expanded`/`Flexible` |
| `Incorrect use of ParentData widget` | `Expanded`/`Flexible` not a direct child of `Flex`; `Positioned` not direct child of `Stack` | move it to be a direct child |
| `RenderBox was not laid out` | cascading side effect | ignore it; fix the unbounded error higher up the trace |

The sections below give worked fixes for each.

---

## RenderFlex Overflowed

**Error:** `A RenderFlex overflowed by X pixels on the right/bottom.`

**Cause:** A `Row` or `Column` contains children that are wider/taller than the available space.

**Fix:** Wrap the overflowing child in `Flexible` or `Expanded`, or constrain its size:

```dart
Row(
  children: [
    Expanded(child: Text('Long text that might overflow')),
    Icon(Icons.info),
  ],
)
```

---

## Vertical Viewport Given Unbounded Height

**Error:** `Vertical viewport was given unbounded height.`

**Cause:** A `ListView` (or other scrollable) is placed inside a `Column` without a bounded height.

**Fix:** Wrap the `ListView` in `Expanded` or give it a fixed height with `SizedBox`:

```dart
Column(
  children: [
    Text('Header'),
    Expanded(
      child: ListView(children: [...]),
    ),
  ],
)
```

---

## InputDecorator Cannot Have Unbounded Width

**Error:** `An InputDecorator...cannot have an unbounded width.`

**Cause:** A `TextField` or similar widget is placed in a context without width constraints.

**Fix:** Wrap it in `Expanded`, `SizedBox`, or any parent that provides width constraints:

```dart
Row(
  children: [
    Expanded(child: TextField()),
  ],
)
```

---

## setState Called During Build

**Error:** `setState() or markNeedsBuild() called during build.`

**Cause:** `setState` or `showDialog` is called directly inside the `build` method.

**Fix:** Trigger state changes in response to user actions, or defer to after the frame using `addPostFrameCallback`:

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Safe to call setState or showDialog here
  });
}
```

---

## ScrollController Attached to Multiple Scroll Views

**Error:** `The ScrollController is attached to multiple scroll views.`

**Cause:** A single `ScrollController` instance is shared across more than one scrollable widget simultaneously.

**Fix:** Ensure each scrollable widget has its own dedicated `ScrollController` instance.

---

## RenderBox Was Not Laid Out

**Error:** `RenderBox was not laid out: ...`

**Cause:** A widget is missing or has unbounded constraints — commonly `ListView` or `Column` without proper size constraints.

**Fix:** Review your widget tree for missing constraints. Common patterns:

- Wrap `ListView` in `Expanded` inside a `Column`.
- Give widgets an explicit `width` or `height` via `SizedBox` or `ConstrainedBox`.

---

## Debugging Layout Issues

- Use the **Flutter Inspector** (in DevTools) to visualize widget constraints.
- Enable **"Show guidelines"** to see layout boundaries.
- Add `debugPaintSizeEnabled = true;` temporarily in your `main()` to paint layout bounds.
- Refer to the [Flutter constraints documentation](https://docs.flutter.dev/ui/layout/constraints) for a deeper understanding of how constraints propagate.

## References

- [Flutter Website GitHub Repository](https://github.com/flutter/website)
