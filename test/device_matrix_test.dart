// Explicit tablet sizes keep the table readable.
// ignore_for_file: avoid_redundant_argument_values

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_device_type/responsive_device_type.dart';

/// Approximate real-device sizes (logical pixels, portrait) and the result
/// with the default breakpoints and [StandardStrategy].
///
/// To add a device, add a row. Use the logical (dp/pt) size, not pixels.
/// Foldables appear twice: folded (cover screen) and unfolded (main screen).
const _matrix = <(String, Size, DeviceType)>[
  // Watches
  ('Apple Watch 41mm', Size(176, 215), DeviceType.watch()),
  ('Apple Watch Ultra', Size(205, 251), DeviceType.watch()),
  ('Pixel Watch', Size(192, 192), DeviceType.watch()),

  // Phones
  ('iPhone SE', Size(375, 667), DeviceType.mobile()),
  ('iPhone 15', Size(393, 852), DeviceType.mobile()),
  ('iPhone 15 Pro Max', Size(430, 932), DeviceType.mobile()),
  ('Pixel 8', Size(412, 915), DeviceType.mobile()),
  ('Galaxy S24', Size(360, 780), DeviceType.mobile()),

  // Foldables, folded (cover screen)
  ('Galaxy Z Fold cover', Size(344, 882), DeviceType.mobile()),
  ('Pixel Fold cover', Size(412, 1001), DeviceType.mobile()),

  // Foldables, unfolded (main screen)
  (
    'Galaxy Z Fold main',
    Size(673, 841),
    DeviceType.tablet(size: TabletSize.small()),
  ),
  (
    'Pixel Fold main',
    Size(841, 701),
    DeviceType.tablet(size: TabletSize.small()),
  ),
  (
    'Surface Duo spanned',
    Size(1114, 720),
    DeviceType.tablet(size: TabletSize.medium()),
  ),

  // Tablets
  ('Nexus 7', Size(600, 960), DeviceType.tablet(size: TabletSize.small())),
  ('iPad mini', Size(744, 1133), DeviceType.tablet(size: TabletSize.medium())),
  (
    'iPad 10th gen',
    Size(820, 1180),
    DeviceType.tablet(size: TabletSize.medium()),
  ),
  (
    'iPad Pro 11"',
    Size(834, 1194),
    DeviceType.tablet(size: TabletSize.medium()),
  ),

  // Large screens
  ('iPad Pro 12.9"', Size(1024, 1366), DeviceType.largeScreen()),
  ('iPad Pro 13" (M4)', Size(1032, 1376), DeviceType.largeScreen()),
  ('Desktop 1080p', Size(1920, 1080), DeviceType.largeScreen()),
];

void main() {
  group('device matrix (StandardStrategy)', () {
    for (final (name, size, expected) in _matrix) {
      test(name, () {
        expect(DeviceType.fromSize(size), expected);
        // Shortest side, so rotation must not change the result.
        expect(DeviceType.fromSize(size.flipped), expected);
      });
    }
  });

  group('device matrix: desktop windows', () {
    const strict = DeviceBreakpointsData(strategy: StrictTabletStrategy());
    const width = DeviceBreakpointsData(strategy: WindowWidthStrategy());

    for (final size in const [Size(1366, 768), Size(1512, 982)]) {
      test('laptop $size', () {
        expect(DeviceType.fromSize(size), isA<DeviceTypeTablet>());
        expect(
          DeviceType.fromSize(size, breakpoints: strict),
          isA<DeviceTypeLargeScreen>(),
        );
        expect(
          DeviceType.fromSize(size, breakpoints: width),
          isA<DeviceTypeLargeScreen>(),
        );
      });
    }
  });
}
