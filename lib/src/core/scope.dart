import 'package:flutter/material.dart';
import 'package:responsive_device_type/src/models/breakpoints.dart';
import 'package:responsive_device_type/src/models/device_type.dart';

/// A widget that provides custom device breakpoints to its descendants.
///
/// This widget uses [InheritedWidget] to make [DeviceBreakpointsData] available
/// throughout the widget tree. Descendants can access the breakpoints using
/// [DeviceBreakpoints.of] or [DeviceBreakpoints.maybeOf].
///
/// If no custom breakpoints are provided, default breakpoints will be used.
///
/// Example:
/// ```dart
/// DeviceBreakpoints(
///   breakpoints: DeviceBreakpointsData(
///     mobile: 480,
///     tablet: 768,
///     desktop: 1024,
///   ),
///   child: MyApp(),
/// )
/// ```
///
/// See also:
///  * [DeviceBreakpointsData], which defines the breakpoint values.
///  * [DeviceType], the enumeration of device types.
class DeviceBreakpoints extends StatelessWidget {
  /// Creates a widget that provides device breakpoints to its descendants.
  ///
  /// The [child] argument is required and represents the widget subtree that
  /// will have access to these breakpoints.
  ///
  /// The [breakpoints] argument is optional. If not provided, default
  /// breakpoints will be used.
  const DeviceBreakpoints({
    required this.child,
    super.key,
    this.breakpoints = _defaultBreakpoints,
  });

  /// The custom breakpoints to use for device classification.
  ///
  /// These breakpoints determine the threshold widths for classifying
  /// devices as mobile, tablet, or desktop.
  final DeviceBreakpointsData breakpoints;

  /// The widget below this widget in the tree.
  final Widget child;

  static const DeviceBreakpointsData _defaultBreakpoints =
      DeviceBreakpointsData();

  /// Returns the [DeviceBreakpointsData] from the nearest ancestor.
  ///
  /// If no [DeviceBreakpoints] widget is found in the widget tree,
  /// this method returns the default breakpoints.
  ///
  /// Calling this method will create a dependency on the nearest
  /// [DeviceBreakpoints] widget, causing the calling widget to rebuild
  /// when the breakpoints change.
  ///
  /// Example:
  /// ```dart
  /// final breakpoints = DeviceBreakpoints.of(context);
  /// final deviceType = breakpoints.classify(MediaQuery.sizeOf(context));
  /// ```
  static DeviceBreakpointsData of(BuildContext context) {
    return maybeOf(context) ?? _defaultBreakpoints;
  }

  /// Returns the [DeviceBreakpointsData] from the nearest ancestor,
  /// or `null` if none exists.
  ///
  /// Unlike [of], this method returns `null` instead of default breakpoints
  /// when no [DeviceBreakpoints] widget is found in the tree.
  ///
  /// This is useful when you need to check whether custom breakpoints
  /// have been explicitly provided.
  ///
  /// Example:
  /// ```dart
  /// final breakpoints = DeviceBreakpoints.maybeOf(context);
  /// if (breakpoints != null) {
  ///   // Custom breakpoints are available
  /// }
  /// ```
  static DeviceBreakpointsData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_DeviceBreakpointsScope>()
        ?.breakpoints;
  }

  /// Returns the current [DeviceType] based on screen size and breakpoints.
  ///
  /// This is a convenience method that combines [of] with [MediaQuery.sizeOf]
  /// and [DeviceBreakpointsData.classify] to determine the device type.
  ///
  /// The method retrieves breakpoints from the widget tree (or uses defaults)
  /// and classifies the current screen size.
  ///
  /// Example:
  /// ```dart
  /// final deviceType = DeviceBreakpoints.deviceTypeOf(context);
  /// if (deviceType == DeviceType.mobile) {
  ///   return MobileLayout();
  /// }
  /// ```
  static DeviceType deviceTypeOf(BuildContext context) {
    final breakpoints = of(context);
    final size = MediaQuery.sizeOf(context);
    return breakpoints.classify(size);
  }

  /// Returns the current [DeviceType] or `null` if no custom breakpoints exist.
  ///
  /// Similar to [deviceTypeOf], but returns `null` when no [DeviceBreakpoints]
  /// widget is found in the tree, instead of using default breakpoints.
  ///
  /// This is useful when you want to handle the absence of custom breakpoints
  /// differently.
  ///
  /// Example:
  /// ```dart
  /// final deviceType = DeviceBreakpoints.maybeDeviceTypeOf(context);
  /// if (deviceType == null) {
  ///   // No custom breakpoints configured
  ///   return DefaultLayout();
  /// }
  /// ```
  static DeviceType? maybeDeviceTypeOf(BuildContext context) {
    final breakpoints = maybeOf(context);
    if (breakpoints == null) return null;
    final size = MediaQuery.sizeOf(context);
    return breakpoints.classify(size);
  }

  @override
  Widget build(BuildContext context) {
    return _DeviceBreakpointsScope(breakpoints: breakpoints, child: child);
  }
}

final class _DeviceBreakpointsScope extends InheritedWidget {
  const _DeviceBreakpointsScope({
    required this.breakpoints,
    required super.child,
  });

  final DeviceBreakpointsData breakpoints;

  @override
  bool updateShouldNotify(_DeviceBreakpointsScope oldWidget) {
    return breakpoints != oldWidget.breakpoints;
  }
}
