---
name: flutter-ui-ux
description: |
  Build UI for the Fantavacanze app: screens, custom widgets, theming, and animations,
  the project way (bloc-driven, design-system spacing, Italian copy, Clean Architecture).
  Use when:
  (1) Building a Flutter screen or widget
  (2) Theming / styling with the app's color + size system
  (3) Adding animations or micro-interactions
  (4) Extracting a reusable widget into core/widgets
  For layouts that adapt across screen sizes use flutter-responsive-ui; for layout
  exceptions use flutter-errors.
---

# Flutter UI/UX (Fantavacanze)

Build beautiful, consistent UI **the way this codebase already does it**. Do not introduce
new patterns (no Riverpod/GetX/Provider for UI state, no ad-hoc color literals, no English
copy). Reuse before creating.

## Non-negotiables for this project

| Rule | Why / How |
|---|---|
| **State via BLoC/Cubit** | UI reads state with `BlocBuilder`/`BlocSelector`, side effects with `BlocListener`. No business logic in widgets. See [[bloc]]. |
| **Colors via context extension** | `context.primaryColor`, `context.bgColor`, `context.secondaryBgColor`, `context.textPrimaryColor`, `context.textSecondaryColor`, `context.borderColor`, `context.accentColor` (`lib/core/extensions/colors_extension.dart`). Never `Color(0x…)` in widgets. Theme is `AppThemeCubit` (dark/light). |
| **Spacing/radii/fonts via `ThemeSizes`** | `lib/core/theme/sizes.dart` — `xs/sm/md/lg/xl/xxl`, `borderRadius*`, `cardRadius*`, `fontSize*`, `icon*`, `avatarSize`, `imageThumbSize`. No magic numbers. |
| **Italian copy** | Every user-facing string in Italian. Error messages too. |
| **Clean Architecture** | Widgets live in `presentation/`; they never touch Supabase/Hive directly. See [[clean-architecture]]. |
| **Reuse shared widgets** | Check `lib/core/widgets/` before building (catalog below). |

## Shared widget catalog (`lib/core/widgets/`)

Reach for these before writing new ones:

- **Feedback / state**: `loader.dart`, `empty_state.dart`, `info_banner.dart`,
  `info_container.dart`, `notification_badge.dart`, `promo_tag.dart`, `plan_label.dart`
- **Buttons**: `buttons/gradient_option_button.dart`, `buttons/modern_icon_button.dart`,
  `buttons/danger_action_button.dart`, `buttons/animated_share_button.dart`,
  `buttons/page_redirection_card.dart`, `become_premium_button.dart`
- **Dialogs** (`widgets/dialogs/`): `confirmation_dialog.dart`, `form_dialog.dart`,
  `processing_dialog.dart`, `notification_dialog.dart`, `app_information_dialog.dart`,
  `premium_access_dialog.dart`, `gdpr_consent_dialog.dart`
- **Domain**: `leaderboard/`, `participants/participant_card.dart`,
  `in_app_purchase/` (subscription UI), `profile_image_avatar.dart`, `custom_tab_bar.dart`
- **Media**: `media/` (video player, thumbnail), `animated_image.dart`, `rive_asset.dart`

If a needed widget is *almost* there, extend or parameterize it rather than duplicating.

## Building a screen — workflow

1. **Locate the layer**: the page goes under
   `lib/features/<feature>/presentation/pages/…`; reusable pieces under the feature's
   `widgets/` or, if cross-feature, `lib/core/widgets/`.
2. **Wire state**: get data from the feature BLoC/Cubit; `BlocBuilder`/`BlocSelector` to
   render, `BlocListener` for snackbars / navigation / dialogs. Never call a use case from
   a page directly — dispatch an event.
3. **Compose small widgets** with `const` constructors. Pull subtrees into private
   widgets (`_Header`, `_MemoryTile`) — not `_buildXxx()` methods — so they get their own
   build context and `const`-ness.
4. **Style** only via `context.*` colors + `ThemeSizes`. Wrap scaffolds in `SafeArea`.
5. **Adapt** across sizes with [[flutter-responsive-ui]] (LayoutBuilder, Expanded,
   constrained width). Prevent overflow proactively.
6. **Verify** on a small phone and a large one; no overflow stripes.

## Patterns

```dart
// Scope rebuilds: select only what changes, not the whole state.
BlocSelector<LeagueBloc, LeagueState, List<League>>(
  selector: (s) => s is LeagueLoaded ? s.leagues : const [],
  builder: (context, leagues) => LeagueList(leagues: leagues),
);

// Side effects in a listener, never in build.
BlocListener<LeagueBloc, LeagueState>(
  listener: (context, state) {
    if (state is LeagueError) {
      showSnackBar(state.message, color: ColorPalette.error);
    }
  },
  child: ...,
);
```

```dart
// A themed tile, project-style: extension colors + ThemeSizes, const, Italian.
class MemoryTile extends StatelessWidget {
  const MemoryTile({super.key, required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.secondaryBgColor,
      elevation: ThemeSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.cardRadiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(ThemeSizes.md),
          child: Text(
            title,
            style: TextStyle(
              color: context.textPrimaryColor,
              fontSize: ThemeSizes.fontSizeMd,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
```

## Animations

Keep them purposeful and cheap (target 60fps). Prefer implicit animations
(`AnimatedContainer`, `AnimatedOpacity`, `AnimatedScale`) for simple state; use an
`AnimationController` + `AnimatedBuilder` (passing a `child` to avoid rebuilds) for custom
work; `Hero` for shared-element transitions. Rive is already wired (`rive_asset.dart`).
Always `dispose()` controllers. Use `RepaintBoundary` around heavy animated subtrees.

## Performance checklist

- `const` constructors everywhere possible.
- Lazy lists/grids (`ListView.builder` / `GridView.builder`).
- `BlocSelector` over `BlocBuilder` when only a slice matters.
- Stable `Key`s for dynamically generated list items.
- No `context.read` in `build` — only in callbacks.
- See `references/performance-optimization.md`.

## Reference files (generic patterns — adapt to the rules above)

- `references/widget-patterns.md` — composition patterns
- `references/animation-patterns.md` — animation recipes
- `references/theme-templates.md` — theming (this project already has `ColorPalette` +
  `ThemeSizes`; use those, don't copy a new ThemeData)
- `references/performance-optimization.md` — rebuild/profiling guidance

> These references are generic Flutter material. When they conflict with the project
> conventions above (e.g. raw `ThemeData`, StatefulWidget-first state, English copy), the
> project conventions win.

## Related

- [[flutter-responsive-ui]] — adaptive layouts across screen sizes
- [[flutter-errors]] — overflow / unbounded constraint fixes
- [[bloc]] — state management UI wires into
- [[clean-architecture]] — where logic belongs
- [[effective-dart]] · [[dart-3-updates]] — idiomatic Dart for widgets
