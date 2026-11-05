# responsive_device_type

Classify the screen as **watch**, **mobile**, **tablet**, or **large screen** with configurable breakpoints, and lay out around the hinge of **foldable and dual-screen** devices. No dependencies besides Flutter.

[![pub package](https://img.shields.io/pub/v/responsive_device_type.svg)](https://pub.dev/packages/responsive_device_type)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Features

- **Sealed `DeviceType`** for exhaustive `switch` expressions, with tablets split into small, medium, and large.
- **`BuildContext` shortcuts**: `context.deviceType`, `context.isCompact`, `context.responsive(...)`.
- **Mobile-first widgets**: `ResponsiveLayout`, `ResponsiveValue`, `DeviceTypeSwitcher`, `DeviceTypeVisibility`. Only `mobile` is required; the rest fall back.
- **Three classification strategies**: shortest side (stable across rotation), window width (Material 3), and strict tablet (desktop-aware).
- **Foldables**: `FoldInfo` reports hinge position and posture (flat, book, tabletop). `DualPaneLayout` places two panes around a separating hinge.
- **Scoped breakpoints** through an `InheritedWidget`, with sensible defaults when you don't add one.

## Install

```yaml
dependencies:
  responsive_device_type: ^1.0.0
```

```dart
import 'package:responsive_device_type/responsive_device_type.dart';
```

## Quick start

No setup needed: without a `DeviceBreakpoints` ancestor, the defaults are used.

```dart
Widget build(BuildContext context) {
  return switch (context.deviceType) {
    DeviceTypeWatch() => const WatchLayout(),
    DeviceTypeMobile() => const MobileLayout(),
    DeviceTypeTablet(size: TabletSizeSmall()) => const TabletLayout(columns: 2),
    DeviceTypeTablet() => const TabletLayout(columns: 3),
    DeviceTypeLargeScreen() => const DesktopLayout(),
  };
}
```

Every access through `context` registers a dependency, so the widget rebuilds when the window is resized, rotated, or folded.

### Quick checks and values

```dart
if (context.isCompact) return const SingleColumn(); // watch or mobile

final columns = context.responsive(mobile: 1, tablet: 2, largeScreen: 4);

if (context.deviceType.isAtLeast(const DeviceType.tablet())) {
  // tablet or large screen
}
```

### Widgets

```dart
// Missing entries fall back: largeScreen -> tablet -> mobile, watch -> mobile.
ResponsiveLayout(
  mobile: const MobileLayout(),
  tablet: const TabletLayout(), // also used on large screens
)

// Builders: only the selected one runs.
DeviceTypeSwitcher(
  mobile: (context) => const MobileLayout(),
  largeScreen: (context) => const DesktopLayout(),
)

ResponsiveValue<double>(
  mobile: 12,
  tablet: 24,
  builder: (context, padding) => Padding(
    padding: EdgeInsets.all(padding),
    child: child,
  ),
)

DeviceTypeVisibility.largeScreen(child: const Sidebar())
DeviceTypeVisibility(showOnWatch: false, child: const Toolbar())

DeviceTypeBuilder(builder: (context, type) => Text(type.name))
```

## How classification works

A **strategy** picks one dimension of the window, and that number is compared with the breakpoints. Every threshold is an exclusive upper bound in logical pixels.

| Type        | Default range | Typical devices |
|-------------|---------------|-----------------|
| watch       | < 300         | Apple Watch, Wear OS |
| mobile      | 300 – 599     | Phones, foldable cover screens |
| tablet      | 600 – 1023    | iPad mini/Air/Pro 11", 7–11" Android tablets, unfolded foldables |
| largeScreen | ≥ 1024        | iPad Pro 12.9"/13", desktops |

Tablets are split by `TabletBreakpoints` (default: small < 720, medium < 900, large ≥ 900). With the defaults, most iPads (744–834) are **medium**; use `TabletBreakpoints.compact()` (680/800) to tell an iPad mini from a full-size iPad.

### Choosing a strategy

| Strategy | Compares | Good for | Watch out for |
|----------|----------|----------|---------------|
| `StandardStrategy` (default) | shortest side | "what kind of device is this?"; stable across rotation | a 1366×768 laptop is a **tablet** |
| `WindowWidthStrategy` | width | layout decisions; matches Material 3 | a phone in landscape becomes a **tablet** |
| `StrictTabletStrategy` | shortest side, plus wide landscape windows → large screen | web and desktop apps | rotation can change tablet ↔ large screen |

```dart
DeviceBreakpoints(
  breakpoints: const DeviceBreakpointsData(strategy: WindowWidthStrategy()),
  child: const MyApp(),
)
```

### Custom breakpoints

```dart
DeviceBreakpoints(
  breakpoints: const DeviceBreakpointsData(
    mobileMax: 640,
    tabletMax: 1100,
    tabletBreakpoints: TabletBreakpoints(smallMax: 760, mediumMax: 960),
  ),
  child: const MyApp(),
)
```

Presets: `DeviceBreakpointsData.defaults()` and `DeviceBreakpointsData.material3()` (window width with 600 / 840, the Material 3 [window size classes](https://m3.material.io/foundations/layout/applying-layout/window-size-classes)). Scopes can be nested; the nearest one wins.

To classify the space a widget actually has rather than the whole window:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final type = context.deviceBreakpoints.classifyFromWidth(constraints.maxWidth);
    return type.isCompact ? const Stacked() : const SideBySide();
  },
)
```

### Custom strategies

```dart
class LongestSideStrategy extends ClassificationStrategy {
  const LongestSideStrategy();

  @override
  DeviceType classify(Size size, DeviceBreakpointsData breakpoints) =>
      classifyExtent(size.longestSide, breakpoints);
}
```

Strategies are compared with `==` when the scope rebuilds. The base class compares by runtime type; add fields to `==` and `hashCode` if your strategy has any.

## Foldables and dual-screen devices

A foldable isn't a separate size class: the same phone is **mobile** when folded and usually a **small tablet** when unfolded. Size classification handles that automatically. What it can't tell you is where the hinge is and how the device is held. That's what `FoldInfo` is for.

```dart
final fold = context.foldInfo;

if (fold.isTabletop) {
  // Half-open with a horizontal hinge: video on top, controls below.
}
if (fold.isBook) {
  // Half-open with a vertical hinge.
}
if (fold.isSeparating) {
  // Don't put content across the hinge.
}
```

| Property | Meaning |
|----------|---------|
| `hasFold` | A fold or hinge is reported in this window (false on cover screens). |
| `posture` | `FoldPosture.flat`, `halfOpened`, or `unknown`. |
| `hingeAxis` | `Axis.vertical` (left/right panes) or `Axis.horizontal` (top/bottom). |
| `isSeparating` | A physical hinge (dual-screen), or a flexible fold that is half-open. |
| `bounds`, `panes(size)` | Hinge rectangle and the two regions around it, in screen coordinates. |

### DualPaneLayout

```dart
DualPaneLayout(
  start: const InboxList(),        // left (or top in tabletop)
  end: const MessageDetail(),      // right (or bottom)
  single: const InboxWithNavigation(), // when there is no separating hinge
)
```

- Respects `Directionality`: in RTL, `start` is on the right.
- Each pane gets its own `MediaQuery` with the pane's size and no display features. `context.deviceType` inside a pane classifies the pane, and nested layouts don't split again. Read `context.foldInfo` *outside* the layout if a pane needs it.
- Hinge coordinates are screen coordinates, so use it full-screen (for example as a route's root, with a `Scaffold` in each pane). If it sits below or beside other UI, pass that offset as `padding`.

### Platform support

| Platform | Size classification | Hinge and posture (`FoldInfo`) |
|----------|---------------------|--------------------------------|
| Android (Galaxy Z Fold, Pixel Fold, Surface Duo, others) | ✅ | ✅ through Jetpack WindowManager |
| iOS / iPadOS | ✅ (adapts when a foldable iPhone folds or unfolds) | ❌ Flutter doesn't report display features on iOS; `hasFold` is `false` |
| Web, desktop | ✅ | ❌ |

### Testing foldable layouts

```dart
await tester.pumpWidget(
  MediaQuery(
    data: const MediaQueryData(
      size: Size(1114, 720),
      displayFeatures: [
        DisplayFeature(
          bounds: Rect.fromLTWH(540, 0, 34, 720),
          type: DisplayFeatureType.hinge,
          state: DisplayFeatureState.postureFlat,
        ),
      ],
    ),
    child: const MyScreen(),
  ),
);
```

Android Studio also ships foldable and dual-screen emulator images.

## Pattern-matching helpers

Besides `switch`, `DeviceType` and `TabletSize` offer `when`, `maybeWhen`, `whenOrNull`, `map`, `maybeMap`, and `mapOrNull`:

```dart
final label = context.deviceType.when(
  watch: () => 'watch',
  mobile: () => 'phone',
  tablet: (size) => '${size.name} tablet',
  largeScreen: () => 'desktop',
);
```

`DeviceTypeTablet` equality includes its size, so `type == const DeviceType.tablet()` only matches medium tablets. Use `type is DeviceTypeTablet` or `type.isTablet` to match any tablet.

## Without a `BuildContext`

```dart
DeviceType.fromSize(const Size(393, 852));          // mobile
DeviceType.fromWidth(900);                          // tablet
const DeviceBreakpointsData.material3().classify(size);
```

## License

MIT. See [LICENSE](LICENSE).
