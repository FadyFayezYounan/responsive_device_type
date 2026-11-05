import 'package:flutter/widgets.dart';

import 'package:responsive_device_type/src/core/scope.dart';
import 'package:responsive_device_type/src/models/device_type.dart';

/// Calls the builder for the current [DeviceType], falling back mobile-first.
///
/// Like `ResponsiveLayout`, but only the selected builder runs, so unused
/// layouts are never created.
///
/// ```dart
/// DeviceTypeSwitcher(
///   mobile: (context) => const MobileLayout(),
///   tablet: (context) => const TabletLayout(),
///   largeScreen: (context) => const DesktopLayout(),
/// )
/// ```
class DeviceTypeSwitcher extends StatelessWidget {
  /// Creates a [DeviceTypeSwitcher].
  const DeviceTypeSwitcher({
    required this.mobile,
    this.watch,
    this.tablet,
    this.largeScreen,
    super.key,
  });

  /// Builder for watch devices. Falls back to [mobile].
  final WidgetBuilder? watch;

  /// Builder for mobile devices, and the final fallback.
  final WidgetBuilder mobile;

  /// Builder for tablet devices. Falls back to [mobile].
  final WidgetBuilder? tablet;

  /// Builder for large screens. Falls back to [tablet], then [mobile].
  final WidgetBuilder? largeScreen;

  @override
  Widget build(BuildContext context) {
    final builder = DeviceBreakpoints.deviceTypeOf(context).select(
      mobile: mobile,
      watch: watch,
      tablet: tablet,
      largeScreen: largeScreen,
    );
    return builder(context);
  }
}
