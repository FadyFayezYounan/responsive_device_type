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
///     mobileMax: 640,
///     tabletMax: 1100,
///   ),
///   child: const MyApp(),
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
/// ## Classification strategies
///
/// * [StandardStrategy] (default): shortest side, stable across rotation.
/// * [WindowWidthStrategy]: window width, like Material 3 size classes.
/// * [StrictTabletStrategy]: shortest side, but wide landscape windows are
///   large screens (good for web and desktop).
///
/// ```dart
/// const breakpoints = DeviceBreakpointsData(
///   strategy: WindowWidthStrategy(),
/// );
/// ```
///
/// ## Foldables
///
/// [FoldInfo] reports the hinge and posture of foldable and dual-screen
/// devices, and [DualPaneLayout] lays out two panes around a separating
/// hinge:
///
/// ```dart
/// if (context.foldInfo.isTabletop) {
///   return const TabletopPlayer();
/// }
/// ```
///
/// See also:
///
///  * [DeviceType], the sealed class hierarchy for device types.
///  * [DeviceBreakpointsData], configurable classification thresholds.
///  * [DeviceBreakpoints], InheritedWidget for per-subtree customization.
///  * [DeviceTypeBuilder], reactive widget for device-aware UIs.
///  * [FoldInfo] and [DualPaneLayout], for foldable devices.
library;

export 'src/core/extensions.dart';
export 'src/core/scope.dart';
export 'src/models/breakpoints.dart' show DeviceBreakpointsData;
export 'src/models/device_type.dart';
export 'src/models/fold_info.dart';
export 'src/models/tablet_size.dart';
export 'src/strategies/classification_strategy.dart'
    show ClassificationStrategy;
export 'src/strategies/standard_strategy.dart' show StandardStrategy;
export 'src/strategies/strict_tablet_strategy.dart' show StrictTabletStrategy;
export 'src/strategies/window_width_strategy.dart' show WindowWidthStrategy;
export 'src/widgets/builder.dart' show DeviceTypeBuilder;
export 'src/widgets/dual_pane_layout.dart' show DualPaneLayout;
export 'src/widgets/responsive_layout.dart' show ResponsiveLayout;
export 'src/widgets/responsive_value.dart' show ResponsiveValue;
export 'src/widgets/switcher.dart' show DeviceTypeSwitcher;
export 'src/widgets/visibility.dart' show DeviceTypeVisibility;
