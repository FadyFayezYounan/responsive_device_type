# responsive_device_type

A lightweight, dependency-free Flutter package that classifies devices into categories (watch, mobile, tablet, largeScreen) based on screen dimensions, with customizable breakpoints and pluggable classification strategies.

[![Pub Version](https://img.shields.io/pub/v/responsive_device_type)](https://pub.dev/packages/responsive_device_type)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Features

- **Simple API**: Get device type with `DeviceTypeBuilder` or `DeviceBreakpoints.deviceTypeOf(context)`
- **Type-safe pattern matching**: Sealed classes enable exhaustive `switch` expressions
- **Customizable breakpoints**: Configure thresholds per-screen via InheritedWidget
- **Multiple strategies**: Choose between standard and strict tablet classification
- **Zero dependencies**: Only requires Flutter SDK
- **Production-ready**: Comprehensive tests and documentation

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  responsive_device_type: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

> **Note:** You don't have to wrap your app with `DeviceBreakpoints`. If you call `DeviceBreakpoints.of(context)` or `DeviceBreakpoints.deviceTypeOf(context)` and no `DeviceBreakpoints` widget is found in the tree, the package will automatically use default breakpoints. Custom breakpoints are only needed when you want to override the defaults.

### 1. Basic Pattern Matching

```dart
import 'package:responsive_device_type/responsive_device_type.dart';

Widget build(BuildContext context) {
  return DeviceTypeBuilder(
    builder: (context, deviceType) {
      return switch (deviceType) {
        DeviceTypeWatch() => const WatchLayout(),
        DeviceTypeMobile() => const MobileLayout(),
        DeviceTypeTablet() => const TabletLayout(),
        DeviceTypeLargeScreen() => const DesktopLayout(),
      };
    },
  );
}
```

### 2. Boolean Checks

```dart
DeviceTypeBuilder(
  builder: (context, deviceType) {
    if (deviceType.isCompact) {
      return const SingleColumnLayout();
    }
    
    if (deviceType.isExpanded) {
      return const MultiColumnLayout();
    }
    
    return const DefaultLayout();
  },
)
```

### 3. Builder Widget

```dart
DeviceTypeBuilder(
  builder: (context, type) {
    final columns = switch (type) {
      DeviceTypeWatch() => 1,
      DeviceTypeMobile() => 2,
      DeviceTypeTablet() => 3,
      DeviceTypeLargeScreen() => 4,
    };
    return GridView.count(
      crossAxisCount: columns,
      children: items,
    );
  },
)
```

## Default Breakpoints

| Device Type   | Shortest Side Range | Example Devices                    |
|---------------|--------------------|------------------------------------|
| Watch         | < 300              | Apple Watch, Galaxy Watch          |
| Mobile        | 300 - 599          | iPhone 14, Pixel 7, Galaxy S23     |
| Tablet        | 600 - 1023         | iPad Pro, Galaxy Tab, Surface Go   |
| LargeScreen   | >= 1024            | Desktop, Laptop, TV                |

## Why `shortestSide`?

This package uses `MediaQuery.size.shortestSide` for classification, ensuring consistent device type regardless of orientation:

- **iPhone 14 Pro (393x852)**: shortestSide = 393 → Mobile
- **iPhone 14 Pro rotated (852x393)**: shortestSide = 393 → Still Mobile
- **iPad Pro 11" (834x1194)**: shortestSide = 834 → Tablet
- **iPad Pro 11" rotated (1194x834)**: shortestSide = 834 → Still Tablet

This prevents unexpected layout changes when users rotate their devices.

## Custom Breakpoints

### App-Wide Customization

Wrap your app with `DeviceBreakpoints`:

```dart
void main() {
  runApp(
    DeviceBreakpoints(
      breakpoints: const DeviceBreakpointsData(
        watchMaxShortestSide: 280,
        mobileMaxShortestSide: 640,
        tabletMaxShortestSide: 1100,
      ),
      child: const MyApp(),
    ),
  );
}
```

### Screen-Specific Customization

Override breakpoints for specific screens:

```dart
DeviceBreakpoints(
  breakpoints: const DeviceBreakpointsData(
    mobileMaxShortestSide: 500,  // Tighter mobile threshold
    strategy: StrictTabletStrategy(),
  ),
  child: const CheckoutScreen(),
)
```

### Material 3 Preset

Use Material Design 3 window size classes:

```dart
const breakpoints = DeviceBreakpointsData.material3();
// Watch: < 300
// Mobile (Compact): < 600
// Tablet (Medium): < 840
// LargeScreen (Expanded): >= 840
```

## Classification Strategies

### StandardStrategy (Default)

Simple classification based only on `shortestSide`. Provides consistent results regardless of orientation.

```dart
const breakpoints = DeviceBreakpointsData(
  strategy: StandardStrategy(),
);
```

**Best for**: Mobile-first apps where orientation shouldn't affect layout category.

### StrictTabletStrategy

Enhanced classification that considers orientation and longest side. In landscape, if the longest side is >= 1366 (common laptop width), classifies as LargeScreen instead of Tablet.

```dart
const breakpoints = DeviceBreakpointsData(
  strategy: StrictTabletStrategy(
    landscapeLongestSideThreshold: 1366,
  ),
);
```

**Best for**: Web and desktop apps where you need to distinguish between actual tablets and desktop browser windows.

#### Comparison

| Screen Size     | Orientation | StandardStrategy | StrictTabletStrategy |
|-----------------|-------------|------------------|---------------------|
| 834x1194        | Portrait    | Tablet           | Tablet              |
| 1194x834        | Landscape   | Tablet           | Tablet              |
| 1400x800        | Landscape   | Tablet           | LargeScreen         |
| 1920x1080       | Landscape   | LargeScreen      | LargeScreen         |

## API Reference

### Device Types

```dart
sealed class DeviceType {
  bool get isWatch;
  bool get isMobile;
  bool get isTablet;
  bool get isLargeScreen;
  bool get isCompact;    // watch || mobile
  bool get isExpanded;   // tablet || largeScreen
  String get name;
  String toSimpleString();
}

final class DeviceTypeWatch extends DeviceType {}
final class DeviceTypeMobile extends DeviceType {}
final class DeviceTypeTablet extends DeviceType {}
final class DeviceTypeLargeScreen extends DeviceType {}
```

### DeviceBreakpointsData

```dart
class DeviceBreakpointsData {
  const DeviceBreakpointsData({
    this.watchMaxShortestSide = 300,
    this.mobileMaxShortestSide = 600,
    this.tabletMaxShortestSide = 1024,
    this.strategy = const StandardStrategy(),
  });

  const DeviceBreakpointsData.defaults();
  const DeviceBreakpointsData.material3();

  DeviceType classify(Size size);
  DeviceType classifyFromMediaQuery(MediaQueryData mediaQuery);
  DeviceBreakpointsData copyWith({...});
}
```

### DeviceBreakpoints

```dart
class DeviceBreakpoints extends StatelessWidget {
  const DeviceBreakpoints({
    required this.child,
    this.breakpoints = const DeviceBreakpointsData(),
  });

  static DeviceBreakpointsData of(BuildContext context);
  static DeviceBreakpointsData? maybeOf(BuildContext context);
  static DeviceType deviceTypeOf(BuildContext context);
  static DeviceType? maybeDeviceTypeOf(BuildContext context);
}
```

### Builder Widgets

```dart
class DeviceTypeBuilder extends StatelessWidget {
  const DeviceTypeBuilder({
    required this.builder,
  });

  final Widget Function(BuildContext context, DeviceType type) builder;
}
```

## Real-World Examples

### Responsive Navigation

```dart
DeviceTypeBuilder(
  builder: (context, deviceType) {
    return Scaffold(
      drawer: deviceType.isCompact ? const AppDrawer() : null,
      body: Row(
        children: [
          if (deviceType.isExpanded)
            NavigationRail(
              destinations: destinations,
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelect,
            ),
          Expanded(child: content),
        ],
      ),
      bottomNavigationBar: deviceType.isCompact
          ? BottomNavigationBar(
              items: navItems,
              currentIndex: selectedIndex,
              onTap: onSelect,
            )
          : null,
    );
  },
)
```

### Adaptive Grid

```dart
DeviceTypeBuilder(
  builder: (context, type) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: switch (type) {
          DeviceTypeWatch() => 1,
          DeviceTypeMobile() => 2,
          DeviceTypeTablet() => 3,
          DeviceTypeLargeScreen() => 4,
        },
        childAspectRatio: type.isCompact ? 1.0 : 1.5,
      ),
      itemBuilder: (context, index) => ProductCard(products[index]),
      itemCount: products.length,
    );
  },
)
```

### Conditional Features

```dart
Widget build(BuildContext context) {
  return DeviceTypeBuilder(
    builder: (context, deviceType) {
      return Card(
        child: Column(
          children: [
            ProductImage(product),
            ProductTitle(product),
            if (deviceType.isExpanded) ...[
              ProductDescription(product),
              ProductReviews(product),
            ],
            ProductPrice(product),
            if (deviceType.isTablet || deviceType.isLargeScreen)
              AddToCartButton(product),
          ],
        ),
      );
    },
  );
}
```

### Master-Detail Layout

```dart
Widget build(BuildContext context) {
  return DeviceTypeBuilder(
    builder: (context, deviceType) {
      if (deviceType.isCompact) {
        return Navigator(
          pages: [
            MaterialPage(child: MasterList(onSelect: selectItem)),
            if (selectedItem != null)
              MaterialPage(child: DetailView(item: selectedItem!)),
          ],
          onPopPage: (route, result) {
            clearSelection();
            return route.didPop(result);
          },
        );
      }

      return Row(
        children: [
          SizedBox(
            width: 300,
            child: MasterList(onSelect: selectItem),
          ),
          Expanded(
            child: selectedItem != null
                ? DetailView(item: selectedItem!)
                : const EmptyState(),
          ),
        ],
      );
    },
  );
}
```

## Testing

### Testing Device-Specific Behavior

```dart
testWidgets('shows mobile layout on phones', (tester) async {
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(size: Size(393, 852)),
      child: const MyApp(),
    ),
  );

  expect(find.byType(MobileLayout), findsOneWidget);
});

testWidgets('shows tablet layout on tablets', (tester) async {
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(size: Size(834, 1194)),
      child: const MyApp(),
    ),
  );

  expect(find.byType(TabletLayout), findsOneWidget);
});
```

### Testing with Custom Breakpoints

```dart
testWidgets('respects custom breakpoints', (tester) async {
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(size: Size(620, 900)),
      child: DeviceBreakpoints(
        breakpoints: const DeviceBreakpointsData(
          mobileMaxShortestSide: 700,
        ),
        child: const MyApp(),
      ),
    ),
  );

  // 620 < 700, so this should be mobile with custom breakpoints
  expect(find.byType(MobileLayout), findsOneWidget);
});
```

## Common Use Cases

### Split-Screen / Multi-Window

On iPadOS and Android, apps can run in split-screen mode. The package handles this correctly:

- iPad in 50% split view (400x1024): shortestSide = 400 → Mobile
- iPad in 70% split view (600x1024): shortestSide = 600 → Tablet

### Foldable Devices

Foldable phones change dimensions when opened/closed:

- Galaxy Fold closed (280x653): shortestSide = 280 → Watch (or Mobile with adjusted threshold)
- Galaxy Fold open (653x884): shortestSide = 653 → Tablet

### Desktop Window Resizing

Desktop apps can be resized to any dimension. Use `StrictTabletStrategy` to distinguish between actual tablets and desktop windows sized to tablet-like proportions.

## Best Practices

**Do:**
- Use pattern matching for exhaustive type handling
- Define breakpoints at app root for consistency
- Use `isCompact` and `isExpanded` for binary layout decisions
- Test with various screen sizes including edge cases
- Consider using `StrictTabletStrategy` for web/desktop apps

**Don't:**
- Hard-code pixel values throughout your app
- Assume orientation from device type
- Forget to handle watch devices (even if unlikely)
- Mix breakpoint definitions across the app

## Performance

- Device type is computed once per build, not cached
- Uses standard MediaQuery dependency tracking
- No additional widget rebuilds beyond MediaQuery changes
- `const` constructors for breakpoints and strategies

## Platform Support

| Platform | Support |
|----------|---------|
| iOS      | ✅       |
| Android  | ✅       |
| Web      | ✅       |
| macOS    | ✅       |
| Windows  | ✅       |
| Linux    | ✅       |

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please read the contributing guidelines before submitting a pull request.
