import 'dart:ui' show Size;

import 'package:responsive_device_type/src/models/breakpoints.dart';
import 'package:responsive_device_type/src/models/device_type.dart';
import 'package:responsive_device_type/src/strategies/classification_strategy.dart';

/// Classifies by the screen's shortest side. This is the default strategy.
///
/// The result does not depend on orientation: rotating a phone to landscape
/// keeps it [DeviceTypeMobile], because its shortest side stays the same.
///
/// | Device type   | Condition (defaults)            |
/// |---------------|---------------------------------|
/// | Watch         | `shortestSide < watchMax` (300) |
/// | Mobile        | `shortestSide < mobileMax` (600)|
/// | Tablet        | `shortestSide < tabletMax` (1024)|
/// | LargeScreen   | `shortestSide >= tabletMax`     |
///
/// ```dart
/// // iPhone 15 (393x852)        -> mobile
/// // iPad Pro 11" (834x1194)    -> tablet (medium)
/// // iPad Pro 12.9" (1024x1366) -> largeScreen (shortest side == 1024)
/// // 1366x768 laptop            -> tablet (shortest side 768)
/// ```
///
/// That last row is the trade-off of this strategy: laptops and desktop
/// windows with a short height count as tablets. For web and desktop apps,
/// use `StrictTabletStrategy` or `WindowWidthStrategy`.
final class StandardStrategy extends ClassificationStrategy {
  /// Creates a [StandardStrategy].
  const StandardStrategy();

  @override
  DeviceType classify(Size size, DeviceBreakpointsData breakpoints) =>
      classifyExtent(size.shortestSide, breakpoints);

  @override
  String toString() => 'StandardStrategy()';
}
