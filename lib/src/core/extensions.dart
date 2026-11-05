import 'package:flutter/widgets.dart';

import 'package:responsive_device_type/src/core/scope.dart';
import 'package:responsive_device_type/src/models/breakpoints.dart';
import 'package:responsive_device_type/src/models/device_type.dart';
import 'package:responsive_device_type/src/models/fold_info.dart';

/// Shortcuts on [BuildContext] for device classification and fold info.
///
/// Each getter creates a dependency on the screen size (and on the nearest
/// `DeviceBreakpoints`), so the calling widget rebuilds when they change.
///
/// ```dart
/// Widget build(BuildContext context) {
///   if (context.isCompact) return const SingleColumn();
///   return const TwoColumns();
/// }
/// ```
///
/// If a getter name clashes with another package, hide it:
/// `import 'package:responsive_device_type/responsive_device_type.dart' hide DeviceTypeContext;`
extension DeviceTypeContext on BuildContext {
  /// The [DeviceType] for the current screen size and nearest breakpoints.
  DeviceType get deviceType => DeviceBreakpoints.deviceTypeOf(this);

  /// The nearest [DeviceBreakpointsData], or the defaults.
  DeviceBreakpointsData get deviceBreakpoints => DeviceBreakpoints.of(this);

  /// Fold or hinge information for the current window.
  FoldInfo get foldInfo => FoldInfo.of(this);

  /// Whether the current device type is [DeviceTypeWatch].
  bool get isWatch => deviceType.isWatch;

  /// Whether the current device type is [DeviceTypeMobile].
  bool get isMobile => deviceType.isMobile;

  /// Whether the current device type is [DeviceTypeTablet].
  bool get isTablet => deviceType.isTablet;

  /// Whether the current device type is [DeviceTypeLargeScreen].
  bool get isLargeScreen => deviceType.isLargeScreen;

  /// Whether the current device type is watch or mobile.
  bool get isCompact => deviceType.isCompact;

  /// Whether the current device type is tablet or large screen.
  bool get isExpanded => deviceType.isExpanded;

  /// Picks a value for the current device type, falling back mobile-first.
  ///
  /// See [DeviceType.select].
  ///
  /// ```dart
  /// final padding = context.responsive(mobile: 12.0, tablet: 24.0);
  /// ```
  T responsive<T>({required T mobile, T? watch, T? tablet, T? largeScreen}) =>
      deviceType.select(
        mobile: mobile,
        watch: watch,
        tablet: tablet,
        largeScreen: largeScreen,
      );
}
