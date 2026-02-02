import 'dart:ui' show Size;

import 'package:flutter/foundation.dart' show immutable;

import 'package:responsive_device_type/src/models/breakpoints.dart';
import 'package:responsive_device_type/src/models/device_type.dart';
import 'package:responsive_device_type/src/strategies/classification_strategy.dart';

/// A simple classification strategy based solely on the screen's shortest side.
///
/// This strategy provides consistent device classification regardless of
/// screen orientation. A phone rotated to landscape will still be classified
/// as mobile because the shortest side (the width in portrait, height in
/// landscape) remains the same.
///
/// ## Classification Logic
///
/// The device type is determined by comparing `size.shortestSide` against
/// the breakpoint thresholds:
///
/// | Device Type   | Condition                                    |
/// |---------------|----------------------------------------------|
/// | Watch         | shortestSide < watchMaxShortestSide (300)    |
/// | Mobile        | shortestSide < mobileMaxShortestSide (600)   |
/// | Tablet        | shortestSide < tabletMaxShortestSide (1024)  |
/// | LargeScreen   | shortestSide >= tabletMaxShortestSide        |
///
/// ## When to Use
///
/// Use [StandardStrategy] when you want:
/// * Simple, predictable classification
/// * Consistent behavior across orientations
/// * Mobile-first responsive design
///
/// ## Example
///
/// ```dart
/// const breakpoints = DeviceBreakpoints(
///   strategy: StandardStrategy(),
/// );
///
/// // iPhone 14 Pro (393x852): shortestSide = 393 -> Mobile
/// // iPad Pro 11" (834x1194): shortestSide = 834 -> Tablet
/// // MacBook Pro (1512x982): shortestSide = 982 -> Tablet
/// ```
///
/// See also:
///
///  * [StrictTabletStrategy], which uses additional heuristics for tablet
///    detection, particularly useful for web and desktop applications.
///  * [ClassificationStrategy], the base class for all strategies.
@immutable
class StandardStrategy extends ClassificationStrategy {
  /// Creates a [StandardStrategy] instance.
  const StandardStrategy();

  @override
  DeviceType classify(Size size, DeviceBreakpointsData breakpoints) {
    final shortestSide = size.shortestSide;

    if (shortestSide < breakpoints.watchMaxShortestSide) {
      return const DeviceTypeWatch();
    }
    if (shortestSide < breakpoints.mobileMaxShortestSide) {
      return const DeviceTypeMobile();
    }
    if (shortestSide < breakpoints.tabletMaxShortestSide) {
      final tabletSize = breakpoints.tabletBreakpoints.classify(shortestSide);
      return DeviceTypeTablet(size: tabletSize);
    }
    return const DeviceTypeLargeScreen();
  }

  @override
  bool operator ==(Object other) => other is StandardStrategy;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'StandardStrategy()';
}
