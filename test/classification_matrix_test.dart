// Explicit tablet sizes keep the tables readable.
// ignore_for_file: avoid_redundant_argument_values

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_device_type/responsive_device_type.dart';

const _watch = DeviceType.watch();
const _mobile = DeviceType.mobile();
const _small = DeviceType.tablet(size: TabletSize.small());
const _medium = DeviceType.tablet(size: TabletSize.medium());
const _large = DeviceType.tablet(size: TabletSize.large());
const _largeScreen = DeviceType.largeScreen();

/// Each threshold is an exclusive upper bound: `b - 1` is below it and `b`
/// is the next class up.
void _expectBoundaries(
  DeviceType Function(double extent) classify,
  List<(double, DeviceType)> table,
) {
  for (final (extent, expected) in table) {
    expect(classify(extent), expected, reason: 'extent $extent');
  }
}

void main() {
  group('exact boundaries', () {
    // Defaults: 300 / 600 / 1024, tablets 720 / 900.
    const defaults = <(double, DeviceType)>[
      (0, _watch),
      (299.9, _watch),
      (300, _mobile),
      (599.9, _mobile),
      (600, _small),
      (719.9, _small),
      (720, _medium),
      (899.9, _medium),
      (900, _large),
      (1023.9, _large),
      (1024, _largeScreen),
      (4000, _largeScreen),
    ];

    test('defaults by shortest side, in both orientations', () {
      const breakpoints = DeviceBreakpointsData();
      _expectBoundaries((e) => breakpoints.classify(Size(e, 5000)), defaults);
      _expectBoundaries((e) => breakpoints.classify(Size(5000, e)), defaults);
    });

    test('defaults by width, ignoring height', () {
      const breakpoints = DeviceBreakpointsData(
        strategy: WindowWidthStrategy(),
      );
      _expectBoundaries((e) => breakpoints.classify(Size(e, 10)), defaults);
      _expectBoundaries((e) => breakpoints.classify(Size(e, 5000)), defaults);
      _expectBoundaries(DeviceType.fromWidth, defaults);
    });

    test('Material 3: 600 / 840 by width, compact tablet sizes', () {
      const breakpoints = DeviceBreakpointsData.material3();
      _expectBoundaries((e) => breakpoints.classify(Size(e, 900)), const [
        (299.9, _watch),
        (300, _mobile),
        (599.9, _mobile),
        (600, _small),
        (679.9, _small),
        (680, _medium),
        (799.9, _medium),
        (800, _large),
        (839.9, _large),
        (840, _largeScreen),
      ]);
    });

    test('custom breakpoints move every boundary', () {
      const breakpoints = DeviceBreakpointsData(
        watchMax: 250,
        mobileMax: 640,
        tabletMax: 1100,
        tabletBreakpoints: TabletBreakpoints(smallMax: 760, mediumMax: 960),
      );
      _expectBoundaries(breakpoints.classifyFromWidth, const [
        (249.9, _watch),
        (250, _mobile),
        (639.9, _mobile),
        (640, _small),
        (759.9, _small),
        (760, _medium),
        (959.9, _medium),
        (960, _large),
        (1099.9, _large),
        (1100, _largeScreen),
      ]);
    });

    test('TabletBreakpoints presets', () {
      _expectBoundaries(
        (e) =>
            DeviceType.tablet(size: const TabletBreakpoints.wide().classify(e)),
        const [
          (767.9, _small),
          (768, _medium),
          (959.9, _medium),
          (960, _large),
        ],
      );
      _expectBoundaries(
        (e) => DeviceType.tablet(
          size: const TabletBreakpoints.compact().classify(e),
        ),
        const [
          (679.9, _small),
          (680, _medium),
          (799.9, _medium),
          (800, _large),
        ],
      );
    });
  });

  group('StrictTabletStrategy', () {
    const strict = DeviceBreakpointsData(strategy: StrictTabletStrategy());

    test('promotes only landscape tablets at or past the threshold', () {
      final table = <(Size, DeviceType)>[
        (const Size(1366, 800), _largeScreen),
        (const Size(1365.9, 800), _medium),
        // Same window in portrait stays a tablet.
        (const Size(800, 1366), _medium),
        // Phones and watches are never promoted, however long.
        (const Size(1500, 500), _mobile),
        (const Size(1500, 250), _watch),
        // Large screens stay large screens.
        (const Size(1024, 1366), _largeScreen),
      ];
      for (final (size, expected) in table) {
        expect(strict.classify(size), expected, reason: '$size');
      }
    });

    test('custom threshold', () {
      const custom = DeviceBreakpointsData(
        strategy: StrictTabletStrategy(landscapeLongestSideThreshold: 1200),
      );
      expect(custom.classify(const Size(1200, 800)), _largeScreen);
      expect(custom.classify(const Size(1199, 800)), _medium);
    });

    test('a square window counts as landscape', () {
      const custom = DeviceBreakpointsData(
        strategy: StrictTabletStrategy(landscapeLongestSideThreshold: 900),
      );
      expect(custom.classify(const Size(900, 900)), _largeScreen);
      expect(custom.classify(const Size(900, 901)), _large);
    });

    test('classifyFromWidth ignores the landscape rule', () {
      expect(strict.classifyFromWidth(800), _medium);
    });
  });

  group('split-screen and multi-window', () {
    // Approximate logical window sizes. Shortest side and width can
    // disagree for the same window, which this table pins down.
    const windows = <(String, Size, DeviceType, DeviceType)>[
      // (name, size, StandardStrategy, WindowWidthStrategy)
      ('iPad Pro 12.9" landscape, 1/2', Size(678, 1024), _small, _small),
      ('iPad Pro 12.9" landscape, 2/3', Size(981, 1024), _large, _large),
      ('iPad Pro 12.9" landscape, 1/3', Size(375, 1024), _mobile, _mobile),
      ('iPad 10th gen landscape, 1/2', Size(585, 820), _mobile, _mobile),
      ('iPad Slide Over', Size(320, 980), _mobile, _mobile),
      ('Phone portrait, top half', Size(412, 450), _mobile, _mobile),
      ('Phone landscape, left half', Size(457, 412), _mobile, _mobile),
      ('Desktop, wide and short', Size(1600, 500), _mobile, _largeScreen),
      ('Desktop, narrow sidebar', Size(280, 900), _watch, _watch),
    ];

    const standard = DeviceBreakpointsData();
    const width = DeviceBreakpointsData(strategy: WindowWidthStrategy());

    for (final (name, size, byShortest, byWidth) in windows) {
      test(name, () {
        expect(standard.classify(size), byShortest);
        expect(width.classify(size), byWidth);
      });
    }
  });

  group('equality and ordering', () {
    const all = <DeviceType>[
      _watch,
      _mobile,
      _small,
      _medium,
      _large,
      _largeScreen,
    ];

    test('every value equals only itself', () {
      for (final a in all) {
        for (final b in all) {
          expect(a == b, identical(a, b), reason: '$a == $b');
        }
      }
      expect(all.toSet(), hasLength(all.length));
    });

    test('equal values from different sources share a hash code', () {
      final fromSize = DeviceType.fromSize(const Size(744, 1133));
      expect(fromSize, _medium);
      expect(fromSize.hashCode, _medium.hashCode);
      expect(DeviceType.fromWidth(1500).hashCode, _largeScreen.hashCode);
    });

    test('a tablet defaults to medium', () {
      expect(const DeviceType.tablet(), _medium);
    });

    test('isAtLeast and isAtMost follow watch < mobile < tablet < large', () {
      int rank(DeviceType t) => switch (t) {
        DeviceTypeWatch() => 0,
        DeviceTypeMobile() => 1,
        DeviceTypeTablet() => 2,
        DeviceTypeLargeScreen() => 3,
      };
      for (final a in all) {
        for (final b in all) {
          expect(a.isAtLeast(b), rank(a) >= rank(b), reason: '$a >= $b');
          expect(a.isAtMost(b), rank(a) <= rank(b), reason: '$a <= $b');
        }
      }
    });

    test('isCompact and isExpanded split at tablet', () {
      for (final t in all) {
        expect(t.isCompact, t is DeviceTypeWatch || t is DeviceTypeMobile);
        expect(t.isExpanded, !t.isCompact);
      }
    });
  });
}
