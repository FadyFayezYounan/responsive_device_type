import 'dart:ui' show Size;

import 'package:responsive_device_type/src/models/breakpoints.dart';
import 'package:responsive_device_type/src/models/device_type.dart';
import 'package:responsive_device_type/src/strategies/classification_strategy.dart';

/// Classifies by the window's current width, like Material 3 window size
/// classes.
///
/// Unlike `StandardStrategy`, the result changes with orientation and window
/// size: a phone rotated to landscape (852 wide) becomes a tablet, and a
/// desktop window dragged narrow becomes mobile. Use it when the type drives
/// layout decisions (columns, navigation rail vs bar) rather than
/// "what device is this?".
///
/// This is the strategy used by [DeviceBreakpointsData.material3].
///
/// ```dart
/// const breakpoints = DeviceBreakpointsData(strategy: WindowWidthStrategy());
///
/// // iPhone 15 portrait (393x852)  -> mobile
/// // iPhone 15 landscape (852x393) -> tablet
/// // 1366x768 laptop               -> largeScreen
/// ```
final class WindowWidthStrategy extends ClassificationStrategy {
  /// Creates a [WindowWidthStrategy].
  const WindowWidthStrategy();

  @override
  DeviceType classify(Size size, DeviceBreakpointsData breakpoints) =>
      classifyExtent(size.width, breakpoints);

  @override
  String toString() => 'WindowWidthStrategy()';
}
