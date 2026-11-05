import 'dart:ui' show Size;

import 'package:flutter/foundation.dart' show immutable, protected;

import 'package:responsive_device_type/src/models/breakpoints.dart';
import 'package:responsive_device_type/src/models/device_type.dart';

/// Decides which dimension of the screen is compared against the
/// [DeviceBreakpointsData] thresholds.
///
/// ## Built-in strategies
///
/// * `StandardStrategy` (default): compares `size.shortestSide`. The result
///   does not change when the device rotates, so it answers "what kind of
///   device is this?". A phone in landscape stays mobile.
/// * `WindowWidthStrategy`: compares `size.width`, like Material 3 window
///   size classes. The result follows the available horizontal space, so a
///   phone in landscape or a narrow desktop window adapts.
/// * `StrictTabletStrategy`: like `StandardStrategy`, but wide landscape
///   windows (laptops, desktop browsers) become large screens instead of
///   tablets.
///
/// ## Custom strategies
///
/// Implement [classify]. [classifyExtent] applies the standard threshold
/// ladder to a single number, so most strategies only choose which number:
///
/// ```dart
/// class LongestSideStrategy extends ClassificationStrategy {
///   const LongestSideStrategy();
///
///   @override
///   DeviceType classify(Size size, DeviceBreakpointsData breakpoints) =>
///       classifyExtent(size.longestSide, breakpoints);
/// }
/// ```
///
/// Strategies are compared with `==` when the scope rebuilds, so give
/// strategies with fields a value-based `==` and `hashCode`.
@immutable
abstract class ClassificationStrategy {
  /// Creates a classification strategy.
  const ClassificationStrategy();

  /// Classifies a screen of the given [size] using [breakpoints].
  DeviceType classify(Size size, DeviceBreakpointsData breakpoints);

  /// Classifies a single [width] using [breakpoints].
  ///
  /// The default implementation applies [classifyExtent] to [width]
  /// directly. Useful with `LayoutBuilder` constraints.
  DeviceType classifyFromWidth(
    double width,
    DeviceBreakpointsData breakpoints,
  ) => classifyExtent(width, breakpoints);

  /// Applies the threshold ladder (watch → mobile → tablet → large screen)
  /// to a single [extent] in logical pixels.
  @protected
  DeviceType classifyExtent(double extent, DeviceBreakpointsData breakpoints) {
    if (extent < breakpoints.watchMax) return const DeviceType.watch();
    if (extent < breakpoints.mobileMax) return const DeviceType.mobile();
    if (extent < breakpoints.tabletMax) {
      return DeviceType.tablet(
        size: breakpoints.tabletBreakpoints.classify(extent),
      );
    }
    return const DeviceType.largeScreen();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other.runtimeType == runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
