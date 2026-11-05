import 'package:flutter/widgets.dart';

import 'package:responsive_device_type/src/core/scope.dart';
import 'package:responsive_device_type/src/models/device_type.dart';

/// Shows the widget for the current [DeviceType], falling back mobile-first.
///
/// Only [mobile] is required. Missing widgets fall back to the next smaller
/// type that has one: `largeScreen → tablet → mobile` and `watch → mobile`.
///
/// ```dart
/// ResponsiveLayout(
///   mobile: const MobileLayout(),
///   tablet: const TabletLayout(), // also used for large screens
/// )
/// ```
///
/// All widgets are created up front. If they are expensive to build, use
/// `DeviceTypeSwitcher`, which takes builders.
class ResponsiveLayout extends StatelessWidget {
  /// Creates a [ResponsiveLayout].
  const ResponsiveLayout({
    required this.mobile,
    this.watch,
    this.tablet,
    this.largeScreen,
    super.key,
  });

  /// Widget for watch devices. Falls back to [mobile].
  final Widget? watch;

  /// Widget for mobile devices, and the final fallback.
  final Widget mobile;

  /// Widget for tablet devices. Falls back to [mobile].
  final Widget? tablet;

  /// Widget for large screens. Falls back to [tablet], then [mobile].
  final Widget? largeScreen;

  @override
  Widget build(BuildContext context) {
    return DeviceBreakpoints.deviceTypeOf(context).select(
      mobile: mobile,
      watch: watch,
      tablet: tablet,
      largeScreen: largeScreen,
    );
  }
}
