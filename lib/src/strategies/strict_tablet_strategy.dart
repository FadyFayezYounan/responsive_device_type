import 'dart:ui' show Size;

import 'package:flutter/foundation.dart' show immutable;

import 'package:responsive_device_type/src/models/breakpoints.dart';
import 'package:responsive_device_type/src/models/device_type.dart';
import 'package:responsive_device_type/src/strategies/classification_strategy.dart';

/// An enhanced classification strategy with stricter tablet detection.
///
/// This strategy extends the basic shortest-side classification with
/// additional heuristics to better distinguish tablets from large screens,
/// particularly useful for web and desktop applications where windows can
/// be resized to tablet-like dimensions.
///
/// ## Classification Logic
///
/// For watch and mobile classifications, behavior is identical to
/// [StandardStrategy]. For tablet vs large screen distinction, this strategy
/// considers screen orientation:
///
/// In **portrait** orientation (height > width):
/// * Uses standard `shortestSide` comparison
///
/// In **landscape** orientation (width >= height):
/// * If `longestSide >= landscapeLongestSideThreshold` (default 1366),
///   classifies as [DeviceTypeLargeScreen] instead of [DeviceTypeTablet]
///
/// ## Rationale
///
/// The threshold of 1366 pixels is chosen because:
/// * Common laptop width: 1366x768 (most common laptop resolution)
/// * Full HD: 1920x1080
/// * MacBook Pro: 1512x982 (scaled)
///
/// A browser window sized to 900x600 (tablet-like shortest side) would still
/// be classified as a tablet with [StandardStrategy], but with
/// [StrictTabletStrategy], if the longest side is >= 1366, it's recognized
/// as a desktop/laptop.
///
/// ## When to Use
///
/// Use [StrictTabletStrategy] when:
/// * Building web applications that run in desktop browsers
/// * Building desktop applications with resizable windows
/// * You need to distinguish between actual tablets and desktop windows
///   sized to tablet-like proportions
///
/// ## Example
///
/// ```dart
/// const breakpoints = DeviceBreakpoints(
///   strategy: StrictTabletStrategy(),
/// );
///
/// // Tablet (834x1194, portrait): -> Tablet
/// // Tablet (1194x834, landscape): -> Tablet (1194 < 1366)
/// // Desktop window (1400x800): -> LargeScreen (1400 >= 1366)
/// // Desktop window (900x600): -> Tablet (900 < 1366)
/// ```
///
/// See also:
///
///  * [StandardStrategy], the simpler default strategy.
///  * [ClassificationStrategy], the base class for all strategies.
@immutable
class StrictTabletStrategy extends ClassificationStrategy {
  /// Creates a [StrictTabletStrategy] with the given threshold.
  ///
  /// The [landscapeLongestSideThreshold] determines the minimum longest-side
  /// value (in landscape orientation) above which a device is classified as
  /// [DeviceTypeLargeScreen] instead of [DeviceTypeTablet].
  ///
  /// Defaults to 1366, which corresponds to the most common laptop resolution.
  const StrictTabletStrategy({this.landscapeLongestSideThreshold = 1366})
    : assert(
        landscapeLongestSideThreshold > 0,
        'landscapeLongestSideThreshold must be positive',
      );

  /// The minimum longest-side value in landscape orientation above which
  /// a device is classified as [DeviceTypeLargeScreen].
  ///
  /// Default value is 1366, matching common laptop resolutions.
  final double landscapeLongestSideThreshold;

  @override
  DeviceType classify(Size size, DeviceBreakpointsData breakpoints) {
    final shortestSide = size.shortestSide;
    final longestSide = size.longestSide;
    final isLandscape = size.width >= size.height;

    // Watch and mobile classification remains the same
    if (shortestSide < breakpoints.watchMaxShortestSide) {
      return const DeviceTypeWatch();
    }
    if (shortestSide < breakpoints.mobileMaxShortestSide) {
      return const DeviceTypeMobile();
    }

    // For tablet vs large screen, apply stricter checks in landscape
    if (shortestSide < breakpoints.tabletMaxShortestSide) {
      // In landscape, if the longest side is large enough, treat as large screen
      if (isLandscape && longestSide >= landscapeLongestSideThreshold) {
        return const DeviceTypeLargeScreen();
      }
      return const DeviceTypeTablet();
    }

    return const DeviceTypeLargeScreen();
  }

  @override
  bool operator ==(Object other) =>
      other is StrictTabletStrategy &&
      other.landscapeLongestSideThreshold == landscapeLongestSideThreshold;

  @override
  int get hashCode => Object.hash(runtimeType, landscapeLongestSideThreshold);

  @override
  String toString() =>
      'StrictTabletStrategy(landscapeLongestSideThreshold: $landscapeLongestSideThreshold)';
}
