import 'dart:ui' show Size;

import 'package:flutter/foundation.dart';

import 'package:responsive_device_type/src/models/device_type.dart';
import 'package:responsive_device_type/src/models/tablet_size.dart';
import 'package:responsive_device_type/src/strategies/classification_strategy.dart';
import 'package:responsive_device_type/src/strategies/standard_strategy.dart';

/// Defines threshold values for classifying devices into different types.
///
/// Breakpoints determine where the boundaries lie between device categories.
/// The classification uses `shortestSide` of the screen, which provides
/// consistent results regardless of device orientation.
///
/// ## Default Breakpoints
///
/// | Device Type   | Shortest Side Range  | Example Devices              |
/// |---------------|----------------------|------------------------------|
/// | Watch         | < 300                | Apple Watch, Galaxy Watch    |
/// | Mobile        | 300 - 599            | iPhone, Pixel, Galaxy        |
/// | Tablet        | 600 - 1023           | iPad, Galaxy Tab             |
/// | LargeScreen   | >= 1024              | Desktop, Laptop, TV          |
///
/// ## Custom Breakpoints
///
/// You can customize breakpoints for your application:
///
/// ```dart
/// const customBreakpoints = DeviceBreakpoints(
///   watchMaxShortestSide: 280,
///   mobileMaxShortestSide: 640,
///   tabletMaxShortestSide: 1100,
/// );
/// ```
///
/// ## Classification Strategies
///
/// Breakpoints work together with [ClassificationStrategy] to determine
/// device types. You can customize the strategy:
///
/// ```dart
/// const breakpoints = DeviceBreakpointsData(
///   strategy: StrictTabletStrategy(),
/// );
/// ```
///
/// See also:
///
///  * [DeviceBreakpointsScope], which provides breakpoints to a widget subtree.
///  * [ClassificationStrategy], which defines how breakpoints are applied.
///  * [StandardStrategy], the default classification strategy.
///  * [StrictTabletStrategy], an alternative with stricter tablet detection.
@immutable
final class DeviceBreakpointsData with Diagnosticable {
  /// Creates breakpoints with the specified thresholds.
  ///
  /// All threshold values must be positive and in ascending order:
  /// `watchMaxShortestSide < mobileMaxShortestSide < tabletMaxShortestSide`
  ///
  /// The [strategy] determines how these thresholds are applied to classify
  /// devices. Defaults to [StandardStrategy].
  ///
  /// The [tabletBreakpoints] parameter defines the size thresholds for
  /// classifying tablets into small, medium, and large categories.
  const DeviceBreakpointsData({
    this.watchMaxShortestSide = 300,
    this.mobileMaxShortestSide = 600,
    this.tabletMaxShortestSide = 1024,
    this.tabletBreakpoints = const TabletBreakpoints.defaults(),
    this.strategy = const StandardStrategy(),
  }) : assert(
         watchMaxShortestSide > 0,
         'watchMaxShortestSide must be positive',
       ),
       assert(
         mobileMaxShortestSide > 0,
         'mobileMaxShortestSide must be positive',
       ),
       assert(
         tabletMaxShortestSide > 0,
         'tabletMaxShortestSide must be positive',
       ),
       assert(
         watchMaxShortestSide < mobileMaxShortestSide,
         'watchMaxShortestSide must be less than mobileMaxShortestSide',
       ),
       assert(
         mobileMaxShortestSide < tabletMaxShortestSide,
         'mobileMaxShortestSide must be less than tabletMaxShortestSide',
       );

  /// Creates breakpoints with default values.
  ///
  /// Equivalent to `DeviceBreakpoints()` but explicitly named for clarity.
  ///
  /// Default values:
  /// * Watch: shortestSide < 300
  /// * Mobile: shortestSide < 600
  /// * Tablet: shortestSide < 1024
  /// * LargeScreen: shortestSide >= 1024
  const DeviceBreakpointsData.defaults()
    : watchMaxShortestSide = 300,
      mobileMaxShortestSide = 600,
      tabletMaxShortestSide = 1024,
      tabletBreakpoints = const TabletBreakpoints.defaults(),
      strategy = const StandardStrategy();

  /// Creates breakpoints aligned with Material Design 3 guidelines.
  ///
  /// Material 3 defines window size classes:
  /// * Compact: width < 600dp (maps to Mobile)
  /// * Medium: 600dp <= width < 840dp (maps to Tablet)
  /// * Expanded: width >= 840dp (maps to LargeScreen)
  ///
  /// Note: Material 3 doesn't define a watch category, so we use 300dp.
  ///
  /// See: https://m3.material.io/foundations/layout/applying-layout/window-size-classes
  const DeviceBreakpointsData.material3()
    : watchMaxShortestSide = 300,
      mobileMaxShortestSide = 600,
      tabletMaxShortestSide = 840,
      tabletBreakpoints = const TabletBreakpoints.compact(),
      strategy = const StandardStrategy();

  /// Maximum shortest side for watch devices.
  ///
  /// Devices with `shortestSide < watchMaxShortestSide` are classified as
  /// [DeviceTypeWatch].
  ///
  /// Default: 300
  final double watchMaxShortestSide;

  /// Maximum shortest side for mobile devices.
  ///
  /// Devices with `shortestSide >= watchMaxShortestSide` and
  /// `shortestSide < mobileMaxShortestSide` are classified as [DeviceTypeMobile].
  ///
  /// Default: 600 (Material Design compact breakpoint)
  final double mobileMaxShortestSide;

  /// Maximum shortest side for tablet devices.
  ///
  /// Devices with `shortestSide >= mobileMaxShortestSide` and
  /// `shortestSide < tabletMaxShortestSide` are classified as [DeviceTypeTablet].
  ///
  /// Default: 1024
  final double tabletMaxShortestSide;

  /// Breakpoints for tablet size classification.
  ///
  /// Use [TabletBreakpoints.defaults()], [TabletBreakpoints.compact()],
  /// [TabletBreakpoints.wide()], or create custom breakpoints.
  ///
  /// Default: [TabletBreakpoints.defaults()]
  final TabletBreakpoints tabletBreakpoints;

  /// The strategy used to classify devices.
  ///
  /// Different strategies can produce different results for the same
  /// screen dimensions. See [ClassificationStrategy] for details.
  ///
  /// Default: [StandardStrategy]
  final ClassificationStrategy strategy;

  /// Classifies a device based on the given screen [size].
  ///
  /// Delegates to the [strategy] to perform the classification.
  ///
  /// ```dart
  /// final breakpoints = DeviceBreakpoints();
  /// final type = breakpoints.classify(Size(393, 852)); // Mobile
  /// ```
  DeviceType classify(Size size) => strategy.classify(size, this);

  /// Classifies a device based on the given [width].
  ///
  /// Unlike [classify] which uses the shortest side of a [Size],
  /// this method uses the provided [width] directly.
  ///
  /// ```dart
  /// final breakpoints = DeviceBreakpoints();
  /// final type = breakpoints.classifyFromWidth(393); // Mobile
  /// ```
  DeviceType classifyFromWidth(double width) =>
      strategy.classifyFromWidth(width, this);

  /// Creates a copy of these breakpoints with the given fields replaced.
  ///
  /// ```dart
  /// final custom = DeviceBreakpoints().copyWith(
  ///   mobileMaxShortestSide: 640,
  /// );
  /// ```
  DeviceBreakpointsData copyWith({
    double? watchMaxShortestSide,
    double? mobileMaxShortestSide,
    double? tabletMaxShortestSide,
    TabletBreakpoints? tabletBreakpoints,
    ClassificationStrategy? strategy,
  }) {
    return DeviceBreakpointsData(
      watchMaxShortestSide: watchMaxShortestSide ?? this.watchMaxShortestSide,
      mobileMaxShortestSide:
          mobileMaxShortestSide ?? this.mobileMaxShortestSide,
      tabletMaxShortestSide:
          tabletMaxShortestSide ?? this.tabletMaxShortestSide,
      tabletBreakpoints: tabletBreakpoints ?? this.tabletBreakpoints,
      strategy: strategy ?? this.strategy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceBreakpointsData &&
          runtimeType == other.runtimeType &&
          watchMaxShortestSide == other.watchMaxShortestSide &&
          mobileMaxShortestSide == other.mobileMaxShortestSide &&
          tabletMaxShortestSide == other.tabletMaxShortestSide &&
          tabletBreakpoints == other.tabletBreakpoints &&
          strategy == other.strategy;

  @override
  int get hashCode => Object.hash(
    watchMaxShortestSide,
    mobileMaxShortestSide,
    tabletMaxShortestSide,
    tabletBreakpoints,
    strategy,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('watchMaxShortestSide', watchMaxShortestSide))
      ..add(DoubleProperty('mobileMaxShortestSide', mobileMaxShortestSide))
      ..add(DoubleProperty('tabletMaxShortestSide', tabletMaxShortestSide))
      ..add(
        DiagnosticsProperty<TabletBreakpoints>(
          'tabletBreakpoints',
          tabletBreakpoints,
        ),
      )
      ..add(DiagnosticsProperty<ClassificationStrategy>('strategy', strategy));
  }
}
