import 'package:flutter/widgets.dart';

import 'package:responsive_device_type/src/core/scope.dart';
import 'package:responsive_device_type/src/models/device_type.dart';

/// A widget that selects a builder based on the current [DeviceType].
///
/// This is a convenience wrapper around [DeviceBreakpoints.deviceTypeOf] and
/// a `switch` on the device type.
///
/// Example:
/// ```dart
/// DeviceTypeSwitcher(
///   watch: (context) => const WatchLayout(),
///   mobile: (context) => const MobileLayout(),
///   tablet: (context) => const TabletLayout(),
///   largeScreen: (context) => const DesktopLayout(),
/// )
/// ```
class DeviceTypeSwitcher extends StatelessWidget {
  /// Creates a [DeviceTypeSwitcher].
  const DeviceTypeSwitcher({
    required this.watch,
    required this.mobile,
    required this.tablet,
    required this.largeScreen,
    super.key,
  });

  /// Builder for watch layouts.
  final WidgetBuilder watch;

  /// Builder for mobile layouts.
  final WidgetBuilder mobile;

  /// Builder for tablet layouts.
  final WidgetBuilder tablet;

  /// Builder for large-screen layouts.
  final WidgetBuilder largeScreen;

  @override
  Widget build(BuildContext context) {
    final type = DeviceBreakpoints.deviceTypeOf(context);
    return switch (type) {
      DeviceTypeWatch() => watch(context),
      DeviceTypeMobile() => mobile(context),
      DeviceTypeTablet() => tablet(context),
      DeviceTypeLargeScreen() => largeScreen(context),
    };
  }
}
