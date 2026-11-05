# Tablet Subtypes Feature

This document describes the new tablet subtypes feature added to the responsive_device_type package.

## Overview

The package now supports classifying tablets into three size categories: **small**, **medium**, and **large**. This allows developers to create more fine-grained responsive layouts for different tablet sizes.

## Key Components

### 1. TabletSize Enum

```dart
enum TabletSize {
  small,   // < 720dp (e.g., iPad Mini: 744x1133)
  medium,  // 720-899dp (e.g., iPad: 810x1080)
  large,   // >= 900dp (e.g., iPad Pro 11": 834x1194)
}
```

### 2. TabletBreakpoints Class

A new class for defining custom tablet size thresholds:

```dart
// Use preset configurations
const breakpoints = TabletBreakpoints.defaults();  // 720/900
const breakpoints = TabletBreakpoints.compact();   // 680/840
const breakpoints = TabletBreakpoints.wide();      // 768/960

// Or create custom breakpoints
const breakpoints = TabletBreakpoints(
  smallMaxShortestSide: 750,
  mediumMaxShortestSide: 950,
);
```

### 3. Updated DeviceTypeTablet

The `DeviceTypeTablet` class now includes:
- Optional `size` property of type `TabletSize?`
- Convenience getters: `isSmallTablet`, `isMediumTablet`, `isLargeTablet`
- Updated equality and toString to include size

### 4. Updated DeviceBreakpointsData

Now accepts a `tabletBreakpoints` parameter:

```dart
DeviceBreakpointsScope(
  breakpoints: const DeviceBreakpointsData(
    tabletBreakpoints: TabletBreakpoints.wide(),
  ),
  child: MyApp(),
)
```

## Usage Examples

### Pattern Matching with Tablet Sizes

```dart
final layout = switch (deviceType) {
  DeviceTypeTablet(size: TabletSize.small) => SmallTabletLayout(),
  DeviceTypeTablet(size: TabletSize.medium) => MediumTabletLayout(),
  DeviceTypeTablet(size: TabletSize.large) => LargeTabletLayout(),
  DeviceTypeTablet() => DefaultTabletLayout(),  // No size specified
  DeviceTypeMobile() => MobileLayout(),
  _ => DesktopLayout(),
};
```

### Dynamic Column Count

```dart
final columns = switch (deviceType) {
  DeviceTypeWatch() => 1,
  DeviceTypeMobile() => 2,
  DeviceTypeTablet(size: TabletSize.small) => 2,
  DeviceTypeTablet(size: TabletSize.medium) => 3,
  DeviceTypeTablet(size: TabletSize.large) => 4,
  DeviceTypeTablet() => 3,
  DeviceTypeLargeScreen() => 4,
};
```

### Using Getters

```dart
if (deviceType is DeviceTypeTablet) {
  if (deviceType.isSmallTablet) {
    // Handle small tablet
  } else if (deviceType.isMediumTablet) {
    // Handle medium tablet
  } else if (deviceType.isLargeTablet) {
    // Handle large tablet
  }
}
```

### Custom Breakpoints

```dart
DeviceBreakpointsScope(
  breakpoints: const DeviceBreakpointsData(
    mobileMaxShortestSide: 600,
    tabletMaxShortestSide: 1024,
    tabletBreakpoints: TabletBreakpoints(
      smallMaxShortestSide: 750,
      mediumMaxShortestSide: 950,
    ),
  ),
  child: MyApp(),
)
```

## Implementation Details

- The classification happens automatically in both `StandardStrategy` and `StrictTabletStrategy`
- Tablet size is determined based on the `shortestSide` of the screen
- The feature is backward compatible - existing code works without changes
- All 67 existing tests continue to pass

## Files Modified

1. `lib/src/models/device_type.dart` - Added TabletBreakpoints, TabletSize, updated DeviceTypeTablet
2. `lib/src/models/breakpoints.dart` - Added tabletBreakpoints parameter
3. `lib/src/strategies/standard_strategy.dart` - Updated to classify tablet sizes
4. `lib/src/strategies/strict_tablet_strategy.dart` - Updated to classify tablet sizes
5. `example/lib/main.dart` - Updated to showcase tablet size detection

## Branch

This feature is implemented on the `feature/tablet-subtypes` branch.
