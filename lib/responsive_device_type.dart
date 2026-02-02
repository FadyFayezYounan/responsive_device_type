/// A lightweight Flutter package for responsive device classification.
///
/// This package provides a simple, type-safe way to classify devices into
/// categories (watch, mobile, tablet, largeScreen) based on screen dimensions,
/// with customizable breakpoints and pluggable classification strategies.
///
/// ## Quick Start
///
/// Get the device type using the BuildContext extension:
///
/// ```dart
/// Widget build(BuildContext context) {
///   return switch (context.deviceType) {
///     DeviceTypeWatch() => const WatchLayout(),
///     DeviceTypeMobile() => const MobileLayout(),
///     DeviceTypeTablet() => const TabletLayout(),
///     DeviceTypeLargeScreen() => const DesktopLayout(),
///   };
/// }
/// ```
///
/// **Note:** You don't have to wrap your app with [DeviceBreakpoints].
/// If no [DeviceBreakpoints] widget is found in the tree, the package will
/// automatically use default breakpoints.
///
/// ## Custom Breakpoints
///
/// Wrap your app with [DeviceBreakpoints] to customize breakpoints:
///
/// ```dart
/// DeviceBreakpoints(
///   breakpoints: const DeviceBreakpointsData(
///     mobileMaxShortestSide: 640,
///     tabletMaxShortestSide: 1100,
///   ),
///   child: MyApp(),
/// )
/// ```
///
/// ## Boolean Checks
///
/// Use convenience properties for simple checks:
///
/// ```dart
/// if (context.isCompact) {
///   return const SingleColumnLayout();
/// }
/// if (context.isExpanded) {
///   return const MultiColumnLayout();
/// }
/// ```
///
/// ## Classification Strategies
///
/// Choose between standard and strict tablet classification:
///
/// ```dart
/// const breakpoints = DeviceBreakpointsData(
///   strategy: StrictTabletStrategy(), // Better for web/desktop
/// );
/// ```
///
/// See also:
///
///  * [DeviceType], the sealed class hierarchy for device types.
///  * [DeviceBreakpointsData], configurable classification thresholds.
///  * [DeviceBreakpoints], InheritedWidget for per-subtree customization.
///  * [DeviceTypeBuilder], reactive widget for device-aware UIs.
library;

export 'src/core/scope.dart';
export 'src/models/breakpoints.dart' show DeviceBreakpointsData;
export 'src/models/device_type.dart';
export 'src/strategies/classification_strategy.dart'
    show ClassificationStrategy;
export 'src/strategies/standard_strategy.dart' show StandardStrategy;
export 'src/strategies/strict_tablet_strategy.dart' show StrictTabletStrategy;
export 'src/widgets/builder.dart' show DeviceTypeBuilder;
export 'src/widgets/responsive_layout.dart' show ResponsiveLayout;
export 'src/widgets/responsive_value.dart' show ResponsiveValue;
export 'src/widgets/switcher.dart' show DeviceTypeSwitcher;
export 'src/widgets/visibility.dart' show DeviceTypeVisibility;
