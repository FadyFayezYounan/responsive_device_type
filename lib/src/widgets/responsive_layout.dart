import 'package:flutter/widgets.dart';

import 'package:responsive_device_type/src/core/scope.dart';
import 'package:responsive_device_type/src/models/device_type.dart';

/// Picks a per-device widget for the current [DeviceType].
///
/// Example:
/// ```dart
/// ResponsiveLayout(
///   watch: const WatchLayout(),
///   mobile: const MobileLayout(),
///   tablet: const TabletLayout(),
///   largeScreen: const DesktopLayout(),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  /// Creates a [ResponsiveLayout].
  const ResponsiveLayout({
    this.watch,
    this.mobile,
    this.tablet,
    this.largeScreen,
    this.fallback = const SizedBox.shrink(),
    super.key,
  });

  /// Widget for watch devices.
  final Widget? watch;

  /// Widget for mobile devices.
  final Widget? mobile;

  /// Widget for tablet devices.
  final Widget? tablet;

  /// Widget for large-screen devices.
  final Widget? largeScreen;

  /// Widget used when no matching widget is provided.
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    final type = DeviceBreakpoints.deviceTypeOf(context);
    final resolved = switch (type) {
      DeviceTypeWatch() => watch,
      DeviceTypeMobile() => mobile,
      DeviceTypeTablet() => tablet,
      DeviceTypeLargeScreen() => largeScreen,
    };
    return resolved ?? fallback;
  }
}
