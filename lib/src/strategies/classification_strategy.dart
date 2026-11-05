import 'dart:ui' show Size;

import 'package:flutter/widgets.dart' show MediaQueryData;

import 'package:responsive_device_type/src/models/breakpoints.dart';
import 'package:responsive_device_type/src/models/device_type.dart';

/// Base class for device classification strategies.
///
/// Classification strategies define how a device's screen dimensions are
/// mapped to a [DeviceType]. Different strategies can produce different
/// results for the same screen size, allowing for customization based on
/// application requirements.
///
/// ## Built-in Strategies
///
/// The package provides two built-in strategies:
///
/// * [StandardStrategy]: Simple classification based only on `shortestSide`.
///   Provides consistent results regardless of orientation.
///
/// * [StrictTabletStrategy]: Enhanced classification that considers orientation
///   and uses additional heuristics to distinguish tablets from desktops.
///
/// ## Custom Strategies
///
/// You can create custom strategies by extending this class:
///
/// ```dart
/// class MyCustomStrategy extends ClassificationStrategy {
///   const MyCustomStrategy();
///
///   @override
///   DeviceType classify(Size size, DeviceBreakpoints breakpoints) {
///     // Custom classification logic
///   }
/// }
/// ```
///
/// See also:
///
///  * [StandardStrategy], the default classification strategy.
///  * [StrictTabletStrategy], an alternative with stricter tablet detection.
///  * [DeviceBreakpointsData], which holds the threshold values used by strategies.
abstract class ClassificationStrategy {
  /// Creates a classification strategy.
  const ClassificationStrategy();

  /// Classifies a device based on screen [size] using the given [breakpoints].
  ///
  /// The [size] parameter represents the screen dimensions. Classification
  /// typically uses `size.shortestSide` for orientation-independent results.
  ///
  /// Returns a [DeviceType] representing the device classification.
  DeviceType classify(Size size, DeviceBreakpointsData breakpoints);

  /// Classifies a device based on [width] using the given [breakpoints].
  ///
  /// Unlike [classify] which uses the shortest side of a [Size],
  /// this method uses the provided [width] directly for classification.
  ///
  /// Returns a [DeviceType] representing the device classification.
  DeviceType classifyFromWidth(double width, DeviceBreakpointsData breakpoints);

  /// Classifies a device based on [MediaQueryData] using the given [breakpoints].
  ///
  /// This is a convenience method that extracts the size from [mediaQuery]
  /// and delegates to [classify].
  ///
  /// Returns a [DeviceType] representing the device classification.
  DeviceType classifyFromMediaQuery(
    MediaQueryData mediaQuery,
    DeviceBreakpointsData breakpoints,
  ) {
    return classify(mediaQuery.size, breakpoints);
  }
}
