import 'dart:ui' show Size;

import 'package:flutter/foundation.dart';

import 'package:responsive_device_type/src/models/device_type.dart';
import 'package:responsive_device_type/src/models/tablet_size.dart';
import 'package:responsive_device_type/src/strategies/classification_strategy.dart';
import 'package:responsive_device_type/src/strategies/standard_strategy.dart';
import 'package:responsive_device_type/src/strategies/window_width_strategy.dart';

/// Thresholds used to classify a screen into a [DeviceType].
///
/// Every threshold is an exclusive upper bound in logical pixels. Which
/// dimension is compared (shortest side, width, ...) is decided by
/// [strategy].
///
/// ## Defaults (with [StandardStrategy], shortest side)
///
/// | Device type   | Range         | Examples (dp)                              |
/// |---------------|---------------|--------------------------------------------|
/// | Watch         | < 300         | Apple Watch (~162–205), Wear OS (~190–230) |
/// | Mobile        | 300 – 599     | iPhone (375–440), Pixel (412), foldable cover screens |
/// | Tablet        | 600 – 1023    | iPad mini/Air/Pro 11", unfolded foldables  |
/// | LargeScreen   | >= 1024       | iPad Pro 12.9"/13", 1080p+ desktop         |
///
/// ## Custom breakpoints
///
/// ```dart
/// const breakpoints = DeviceBreakpointsData(
///   mobileMax: 640,
///   tabletMax: 1100,
/// );
/// ```
///
/// See also:
///
///  * `DeviceBreakpoints`, which provides these values to a widget subtree.
///  * [ClassificationStrategy], which decides which dimension is compared.
///  * [TabletBreakpoints], which splits tablets into small/medium/large.
@immutable
final class DeviceBreakpointsData with Diagnosticable {
  /// Creates breakpoints with the given thresholds.
  ///
  /// All thresholds must be positive and ascending:
  /// `watchMax < mobileMax < tabletMax`.
  const DeviceBreakpointsData({
    this.watchMax = 300,
    this.mobileMax = 600,
    this.tabletMax = 1024,
    this.tabletBreakpoints = const TabletBreakpoints.defaults(),
    this.strategy = const StandardStrategy(),
  }) : assert(watchMax > 0, 'watchMax must be positive'),
       assert(watchMax < mobileMax, 'watchMax must be less than mobileMax'),
       assert(mobileMax < tabletMax, 'mobileMax must be less than tabletMax');

  /// The default breakpoints. Same as `DeviceBreakpointsData()`.
  const DeviceBreakpointsData.defaults()
    : watchMax = 300,
      mobileMax = 600,
      tabletMax = 1024,
      tabletBreakpoints = const TabletBreakpoints.defaults(),
      strategy = const StandardStrategy();

  /// Breakpoints matching Material 3
  /// [window size classes](https://m3.material.io/foundations/layout/applying-layout/window-size-classes).
  ///
  /// Uses [WindowWidthStrategy], because Material 3 classifies by window
  /// **width**:
  ///
  /// | Material 3 class          | Width       | [DeviceType]  |
  /// |---------------------------|-------------|---------------|
  /// | Compact                   | < 600       | mobile        |
  /// | Medium                    | 600 – 839   | tablet        |
  /// | Expanded, Large, XL       | >= 840      | largeScreen   |
  ///
  /// Material 3 has no watch class; widths below 300 are reported as watch.
  const DeviceBreakpointsData.material3()
    : watchMax = 300,
      mobileMax = 600,
      tabletMax = 840,
      tabletBreakpoints = const TabletBreakpoints.compact(),
      strategy = const WindowWidthStrategy();

  /// Upper bound (exclusive) for [DeviceTypeWatch]. Default: 300.
  final double watchMax;

  /// Upper bound (exclusive) for [DeviceTypeMobile]. Default: 600.
  final double mobileMax;

  /// Upper bound (exclusive) for [DeviceTypeTablet]. Anything at or above
  /// this is [DeviceTypeLargeScreen]. Default: 1024.
  final double tabletMax;

  /// Thresholds that split tablets into [TabletSize.small],
  /// [TabletSize.medium], and [TabletSize.large].
  final TabletBreakpoints tabletBreakpoints;

  /// Decides which dimension of the screen is compared to the thresholds.
  ///
  /// Default: [StandardStrategy] (shortest side).
  final ClassificationStrategy strategy;

  /// Classifies a screen of the given [size] using [strategy].
  ///
  /// ```dart
  /// const DeviceBreakpointsData().classify(const Size(393, 852)); // mobile
  /// ```
  DeviceType classify(Size size) => strategy.classify(size, this);

  /// Classifies a single [width], ignoring height.
  ///
  /// Handy with `LayoutBuilder` to classify the space a widget actually has:
  ///
  /// ```dart
  /// LayoutBuilder(
  ///   builder: (context, constraints) {
  ///     final type = DeviceBreakpoints.of(context)
  ///         .classifyFromWidth(constraints.maxWidth);
  ///     // ...
  ///   },
  /// )
  /// ```
  DeviceType classifyFromWidth(double width) =>
      strategy.classifyFromWidth(width, this);

  /// Returns a copy with the given fields replaced.
  DeviceBreakpointsData copyWith({
    double? watchMax,
    double? mobileMax,
    double? tabletMax,
    TabletBreakpoints? tabletBreakpoints,
    ClassificationStrategy? strategy,
  }) {
    return DeviceBreakpointsData(
      watchMax: watchMax ?? this.watchMax,
      mobileMax: mobileMax ?? this.mobileMax,
      tabletMax: tabletMax ?? this.tabletMax,
      tabletBreakpoints: tabletBreakpoints ?? this.tabletBreakpoints,
      strategy: strategy ?? this.strategy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceBreakpointsData &&
          watchMax == other.watchMax &&
          mobileMax == other.mobileMax &&
          tabletMax == other.tabletMax &&
          tabletBreakpoints == other.tabletBreakpoints &&
          strategy == other.strategy;

  @override
  int get hashCode =>
      Object.hash(watchMax, mobileMax, tabletMax, tabletBreakpoints, strategy);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('watchMax', watchMax))
      ..add(DoubleProperty('mobileMax', mobileMax))
      ..add(DoubleProperty('tabletMax', tabletMax))
      ..add(
        DiagnosticsProperty<TabletBreakpoints>(
          'tabletBreakpoints',
          tabletBreakpoints,
        ),
      )
      ..add(DiagnosticsProperty<ClassificationStrategy>('strategy', strategy));
  }
}
