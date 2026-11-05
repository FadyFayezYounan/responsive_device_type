import 'package:flutter/widgets.dart';

import 'package:responsive_device_type/src/core/scope.dart';
import 'package:responsive_device_type/src/models/device_type.dart';

/// Shows or hides its [child] based on the current [DeviceType].
///
/// Every type is shown by default; turn types off with the `showOn*` flags,
/// or use a named constructor to show on a single type.
///
/// ```dart
/// // Hide on tablets only.
/// DeviceTypeVisibility(
///   showOnTablet: false,
///   child: const CompactToolbar(),
/// )
///
/// // Large screens only.
/// DeviceTypeVisibility.largeScreen(child: const Sidebar())
/// ```
///
/// The [replacement] is shown instead when hidden. The [child] is removed
/// from the tree, not just made invisible, so its state is lost.
class DeviceTypeVisibility extends StatelessWidget {
  /// Creates a [DeviceTypeVisibility] widget.
  const DeviceTypeVisibility({
    required this.child,
    this.replacement = const SizedBox.shrink(),
    this.showOnWatch = true,
    this.showOnMobile = true,
    this.showOnTablet = true,
    this.showOnLargeScreen = true,
    super.key,
  });

  /// Shows [child] only on watch devices.
  const DeviceTypeVisibility.watch({
    required this.child,
    this.replacement = const SizedBox.shrink(),
    this.showOnWatch = true,
    this.showOnMobile = false,
    this.showOnTablet = false,
    this.showOnLargeScreen = false,
    super.key,
  });

  /// Shows [child] only on mobile devices.
  const DeviceTypeVisibility.mobile({
    required this.child,
    this.replacement = const SizedBox.shrink(),
    this.showOnWatch = false,
    this.showOnMobile = true,
    this.showOnTablet = false,
    this.showOnLargeScreen = false,
    super.key,
  });

  /// Shows [child] only on tablets.
  const DeviceTypeVisibility.tablet({
    required this.child,
    this.replacement = const SizedBox.shrink(),
    this.showOnWatch = false,
    this.showOnMobile = false,
    this.showOnTablet = true,
    this.showOnLargeScreen = false,
    super.key,
  });

  /// Shows [child] only on large screens.
  const DeviceTypeVisibility.largeScreen({
    required this.child,
    this.replacement = const SizedBox.shrink(),
    this.showOnWatch = false,
    this.showOnMobile = false,
    this.showOnTablet = false,
    this.showOnLargeScreen = true,
    super.key,
  });

  /// The widget to display when visible.
  final Widget child;

  /// The widget to display when not visible.
  final Widget replacement;

  /// Whether to show on watch devices.
  final bool showOnWatch;

  /// Whether to show on mobile devices.
  final bool showOnMobile;

  /// Whether to show on tablet devices.
  final bool showOnTablet;

  /// Whether to show on large-screen devices.
  final bool showOnLargeScreen;

  @override
  Widget build(BuildContext context) {
    final type = DeviceBreakpoints.deviceTypeOf(context);
    final isVisible = switch (type) {
      DeviceTypeWatch() => showOnWatch,
      DeviceTypeMobile() => showOnMobile,
      DeviceTypeTablet() => showOnTablet,
      DeviceTypeLargeScreen() => showOnLargeScreen,
    };
    return isVisible ? child : replacement;
  }
}
