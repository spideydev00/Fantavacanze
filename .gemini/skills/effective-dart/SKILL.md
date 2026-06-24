---
name: effective-dart
description: "Apply Effective Dart guidelines to write idiomatic, high-quality Dart and Flutter code. Use when writing new Dart code, reviewing pull requests for style compliance, refactoring naming conventions, enforcing type annotations, or running code review checks against Effective Dart standards."
---

# Effective Dart Skill

This skill defines how to write idiomatic, high-quality Dart and Flutter code following Effective Dart guidelines.

---

## 1. Naming Conventions

| Kind | Convention | Example |
|---|---|---|
| Classes, enums, typedefs, type parameters, extensions | `UpperCamelCase` | `MyWidget`, `UserState` |
| Packages, directories, source files | `lowercase_with_underscores` | `user_profile.dart` |
| Import prefixes | `lowercase_with_underscores` | `import '...' as my_prefix;` |
| Variables, parameters, named parameters, functions | `lowerCamelCase` | `userName`, `fetchData()` |

- Capitalize acronyms longer than two letters like words: `HttpRequest`, not `HTTPRequest`.
- Avoid abbreviations unless the abbreviation is more common than the full term.
- Put the **most descriptive noun last** in names.
- Use terms **consistently** throughout the codebase.

---

## 2. Types and Functions

- **Type annotate variables** without initializers.
- Type annotate **fields and top-level variables** if the type isn't obvious.
- **Annotate return types** on function declarations.
- **Annotate parameter types** on function declarations.
- Use `Future<void>` as the return type of async members that produce no value.
- Use class modifiers (`final`, `sealed`, `interface`) to control inheritance.

```dart
// Prefer sealed for exhaustive pattern matching in state classes
sealed class LeagueState extends Equatable {}
final class LeagueLoading extends LeagueState {}
final class LeagueLoaded extends LeagueState {
  const LeagueLoaded(this.leagues);
  final List<League> leagues;
  @override List<Object?> get props => [leagues];
}
```

---

## 3. Style

```bash
dart format .
dart analyze
```

- Format with `dart format` — do not manually format.
- Use **curly braces** for all flow control statements.
- Prefer `final` over `var` when the value won't change.
- Use `const` for compile-time constants.
- Lines **80 characters or fewer** as a guideline.

---

## 4. Comments

**Default to writing no comments.** Add a comment only when the **WHY** is non-obvious: a hidden constraint, a subtle invariant, a workaround for a specific bug, or behavior that would surprise a reader.

```dart
// BAD — comment describes what the code does (already obvious)
// Check if user is premium
if (user.isPremium) { ... }

// GOOD — explains a non-obvious constraint
// Positions 1 and 4 are always unlocked; others depend on premium status.
final isUnlocked = position == 1 || position == 4 || isPremium;
```

When a comment is warranted, use `///` for public API doc comments:

```dart
/// Returns the leagues for the current user, checking local cache first.
Future<Either<Failure, List<League>>> getUserLeagues();
```

- Start doc comments with a **single-sentence summary**.
- Avoid redundancy with surrounding context.
- Do **not** write multi-paragraph docstrings or multi-line comment blocks.
- Do **not** reference the current task, fix, or PR in comments — those belong in the PR description.

---

## 5. Imports and Files

- Prefer **relative import paths** within the same package.
- Do not import from inside another package's `src/` directory.
- Keep files **focused on a single responsibility**.
- Prefer making declarations **private** — only expose what's necessary.

---

## 6. Usage Patterns

```dart
// Use collection literals
final list = [1, 2, 3];
final map = {'key': 'value'};

// Initializing formals
class Point {
  final double x, y;
  Point(this.x, this.y);
}

// rethrow to preserve stack trace
try {
  doSomething();
} catch (e) {
  log(e);
  rethrow;
}
```

- Use `whereType<T>()` to filter a collection by type.
- Initialize fields at their **declaration** when possible.
- Use `on SomeException catch (e)` — avoid broad `catch (e)`.
- Override `hashCode` whenever you override `==`.

---

## 7. Project-Specific Rules

* **User-facing strings and error messages are in Italian.** Never add English strings to the UI.
* Do not add error handling for scenarios that cannot happen. Trust framework guarantees.
* Do not add features, refactors, or abstractions beyond what the task requires.
* Three similar lines is better than a premature abstraction.

---

## 8. Code Review Checks

1. Identifiers follow naming conventions in Section 1.
2. Public API parameters, return types, and uninitialized variables are type-annotated.
3. `dart format --output=none --set-exit-if-changed .` passes.
4. `dart analyze` reports zero issues.
5. Comments explain WHY, not WHAT.
6. User-facing strings are in Italian.

---

## References

- [Effective Dart](https://dart.dev/effective-dart)
