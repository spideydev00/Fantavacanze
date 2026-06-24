---
name: flutter-responsive-ui
description: Build Flutter layouts that adapt to different screen sizes and orientations using LayoutBuilder, MediaQuery, and Flexible/Expanded. Use when a screen must look right across phone sizes (and tablets), avoid overflow on small devices, or constrain content width on large ones. Mobile-first, anchored to this project's theme/sizes conventions.
---

# Responsive & Adaptive Layouts (Fantavacanze)

This is a **mobile** app (iOS/Android social gaming). Optimize first for the range of
phone sizes (small Androids → large iPhones/Pro Max) and tablet, not desktop. Base every
layout decision on **available space**, never on a hardcoded "phone vs tablet" check.

## Core rule

> **Constraints go down. Sizes go up. Parent sets position.**

Most responsive bugs are this rule failing: a child asks for more than the parent allows
(overflow) or the parent gives infinite space (unbounded). See [[flutter-errors]] to fix
the resulting exceptions.

## Measure space the right way

| Need | Use | In this project |
|---|---|---|
| Full window size | `MediaQuery.sizeOf(context)` | or `Constants.getWidth(context)` / `Constants.getHeight(context)` (`lib/core/constants/constants.dart`) |
| Space allocated to *this* subtree | `LayoutBuilder` → `constraints.maxWidth` | preferred for switching layouts |
| Safe area / notch / keyboard insets | `MediaQuery.paddingOf` / `viewInsetsOf` | wrap scaffolds in `SafeArea` |

**Do not**:
- switch layouts on `MediaQuery.orientationOf` / `OrientationBuilder` near the top of the tree — orientation ≠ available width.
- branch on device type ("isTablet"). Use width thresholds instead.

## Spacing & sizing come from the design system

Never hardcode raw pixels for padding, radii or fonts. Use `ThemeSizes`
(`lib/core/theme/sizes.dart`): `ThemeSizes.xs/sm/md/lg/xl/xxl`, `borderRadius*`,
`fontSize*`, `iconSm/Md/Lg/Xl`. Colors come from the context extension
(`context.primaryColor`, `context.bgColor`, `context.textPrimaryColor`, …), never literals.

When a size must scale with the screen, derive it from available width:

```dart
// Card that is 90% of width on phones, capped for large screens.
final width = (Constants.getWidth(context) * 0.9).clamp(0.0, 420.0);
```

## Workflow — make a widget adaptive

1. Identify the widget that overflows or stretches.
2. Wrap it in `LayoutBuilder`; read `constraints.maxWidth`.
3. Pick a breakpoint by space, not device — e.g. `const kWide = 600.0;`.
4. `maxWidth > kWide` → wide layout (e.g. two columns side-by-side via `Row` + `Expanded`).
   `maxWidth <= kWide` → stacked layout (`Column`).
5. Keep all spacing on `ThemeSizes`; keep strings in Italian.
6. Verify: run the app, resize / test on a small device + a tablet, fix overflow.

```dart
class AdaptiveSection extends StatelessWidget {
  const AdaptiveSection({super.key, required this.sidebar, required this.content});

  final Widget sidebar;
  final Widget content;

  static const double _wideBreakpoint = 600.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > _wideBreakpoint) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 240, child: sidebar),
              const SizedBox(width: ThemeSizes.lg),
              Expanded(child: content),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            sidebar,
            const SizedBox(height: ThemeSizes.md),
            content,
          ],
        );
      },
    );
  }
}
```

## Workflow — stop content stretching on large screens

1. For long lists with many items: always `ListView.builder` / `GridView.builder`
   (lazy). For a grid that reflows by space, use
   `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: ...)` so columns
   adjust to width automatically.
2. For forms / text blocks / readable content: wrap in
   `ConstrainedBox(constraints: BoxConstraints(maxWidth: 480))` inside a `Center`,
   so it doesn't span the full width of a tablet.
3. Verify on a tablet that the content is centered and not edge-to-edge.

```dart
Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 480),
    child: GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisSpacing: ThemeSizes.md,
        crossAxisSpacing: ThemeSizes.md,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => MemoryTile(item: items[i]),
    ),
  ),
)
```

## Text that must not overflow

- In a `Row`, wrap variable-length `Text` in `Expanded` (or `Flexible`) and set
  `overflow: TextOverflow.ellipsis`. This is the #1 overflow cause on small phones.
- Respect the user's font scale; do not disable `textScaler`. Test with large fonts.

## Orientation

Don't lock orientation just to dodge layout work — fix the layout instead. If a screen is
genuinely portrait-only by design (e.g. a specific game board), lock it locally for that
route, not globally, and document why.

## Clean Architecture boundary

Responsive code lives in the **presentation** layer only. Widgets decide *how* to lay out;
they never fetch data, call Supabase/Hive, or hold business logic — that stays in
BLoC/Cubit ([[bloc]]) and below ([[clean-architecture]]).

## Related

- [[flutter-errors]] — fix the overflow / unbounded exceptions this prevents
- [[flutter-ui-ux]] — building the widgets themselves, theming, animations
- [[bloc]] · [[clean-architecture]] — where logic belongs
