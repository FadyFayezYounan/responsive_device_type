import 'package:flutter/widgets.dart';
import 'package:responsive_device_type/src/core/scope.dart';

import 'package:responsive_device_type/src/models/device_type.dart';

/// A widget that builds its child based on the current [DeviceType].
///
/// This widget automatically rebuilds when the device classification
/// changes (e.g., on device rotation, window resize, or when the
/// [DeviceBreakpoints] changes).
///
/// ## Basic Usage
///
/// ```dart
/// DeviceTypeBuilder(
///   builder: (context, type) {
///     return switch (type) {
///       DeviceTypeWatch() => const WatchLayout(),
///       DeviceTypeMobile() => const MobileLayout(),
///       DeviceTypeTablet() => const TabletLayout(),
///       DeviceTypeLargeScreen() => const DesktopLayout(),
///     };
///   },
/// )
/// ```
///
/// ## Responsive Grid
///
/// ```dart
/// DeviceTypeBuilder(
///   builder: (context, type) {
///     final columns = switch (type) {
///       DeviceTypeWatch() => 1,
///       DeviceTypeMobile() => 2,
///       DeviceTypeTablet() => 3,
///       DeviceTypeLargeScreen() => 4,
///     };
///     return GridView.count(
///       crossAxisCount: columns,
///       children: items,
///     );
///   },
/// )
/// ```
///
/// ## Custom Breakpoints
///
/// Override scoped breakpoints for this builder:
///
/// ```dart
/// DeviceTypeBuilder(
///   breakpoints: const DeviceBreakpoints(
///     mobileMaxShortestSide: 640,
///   ),
///   builder: (context, type) {
///     return MyWidget(type: type);
///   },
/// )
/// ```
///
/// See also:
///
///  * [DeviceType], the classification result.
///  * [DeviceBreakpointsScope], to customize breakpoints per-subtree.
///  * [DeviceTypeSwitcher], for mapping device types to builders.
///  * [DeviceTypeVisibility], to show or hide content by device type.
///  * [ResponsiveLayout], to provide per-device widgets.
class DeviceTypeBuilder extends StatelessWidget {
  /// Creates a [DeviceTypeBuilder].
  ///
  /// The [builder] callback is invoked with the current [BuildContext]
  /// and [DeviceType] whenever the device classification changes.
  const DeviceTypeBuilder({required this.builder, super.key});

  /// Called to build the child widget.
  ///
  /// The [type] parameter contains the current device classification.
  final Widget Function(BuildContext context, DeviceType type) builder;

  @override
  Widget build(BuildContext context) {
    final deviceType = DeviceBreakpoints.deviceTypeOf(context);
    return builder(context, deviceType);
  }
}
