import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_device_type/responsive_device_type.dart';

void main() {
  group('DeviceBreakpoints constructor', () {
    test('default values', () {
      const breakpoints = DeviceBreakpointsData();

      expect(breakpoints.watchMax, 300);
      expect(breakpoints.mobileMax, 600);
      expect(breakpoints.tabletMax, 1024);
      expect(breakpoints.strategy, isA<StandardStrategy>());
    });

    test('custom values', () {
      const breakpoints = DeviceBreakpointsData(
        watchMax: 280,
        mobileMax: 640,
        tabletMax: 1100,
        strategy: StrictTabletStrategy(),
      );

      expect(breakpoints.watchMax, 280);
      expect(breakpoints.mobileMax, 640);
      expect(breakpoints.tabletMax, 1100);
      expect(breakpoints.strategy, isA<StrictTabletStrategy>());
    });
  });

  group('DeviceBreakpoints.defaults', () {
    test('has correct default values', () {
      const breakpoints = DeviceBreakpointsData.defaults();

      expect(breakpoints.watchMax, 300);
      expect(breakpoints.mobileMax, 600);
      expect(breakpoints.tabletMax, 1024);
      expect(breakpoints.strategy, isA<StandardStrategy>());
    });

    test('equals default constructor', () {
      const defaults = DeviceBreakpointsData.defaults();
      const regular = DeviceBreakpointsData();

      expect(defaults, regular);
    });
  });

  group('DeviceBreakpoints.material3', () {
    test('has Material 3 values', () {
      const breakpoints = DeviceBreakpointsData.material3();

      expect(breakpoints.watchMax, 300);
      expect(breakpoints.mobileMax, 600);
      expect(breakpoints.tabletMax, 840);
      expect(breakpoints.strategy, isA<WindowWidthStrategy>());
    });

    test('classifies by width like Material 3 size classes', () {
      const breakpoints = DeviceBreakpointsData.material3();

      // Compact
      expect(
        breakpoints.classify(const Size(599, 900)),
        isA<DeviceTypeMobile>(),
      );
      // Medium
      expect(
        breakpoints.classify(const Size(600, 300)),
        isA<DeviceTypeTablet>(),
      );
      expect(
        breakpoints.classify(const Size(839, 400)),
        isA<DeviceTypeTablet>(),
      );
      // Expanded
      expect(
        breakpoints.classify(const Size(840, 400)),
        isA<DeviceTypeLargeScreen>(),
      );
      // A phone in landscape is no longer compact.
      expect(
        breakpoints.classify(const Size(852, 393)),
        isA<DeviceTypeLargeScreen>(),
      );
    });
  });

  group('DeviceBreakpoints assertions', () {
    test('watchMax must be positive', () {
      expect(
        () => DeviceBreakpointsData(watchMax: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => DeviceBreakpointsData(watchMax: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('mobileMax must be positive', () {
      expect(
        () => DeviceBreakpointsData(mobileMax: 0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('tabletMax must be positive', () {
      expect(
        () => DeviceBreakpointsData(tabletMax: 0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('values must be in ascending order', () {
      // watch >= mobile
      expect(
        () => DeviceBreakpointsData(watchMax: 600),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => DeviceBreakpointsData(watchMax: 700),
        throwsA(isA<AssertionError>()),
      );

      // mobile >= tablet
      expect(
        () => DeviceBreakpointsData(mobileMax: 1024),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => DeviceBreakpointsData(mobileMax: 1100),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('DeviceBreakpoints.copyWith', () {
    test('copies with new values', () {
      const original = DeviceBreakpointsData();
      final copied = original.copyWith(
        mobileMax: 640,
        strategy: const StrictTabletStrategy(),
      );

      expect(copied.watchMax, 300); // unchanged
      expect(copied.mobileMax, 640); // changed
      expect(copied.tabletMax, 1024); // unchanged
      expect(copied.strategy, isA<StrictTabletStrategy>()); // changed
    });

    test('returns equal object when no changes', () {
      const original = DeviceBreakpointsData();
      final copied = original.copyWith();

      expect(copied, original);
    });
  });

  group('DeviceBreakpoints equality', () {
    test('equal breakpoints are equal', () {
      const a = DeviceBreakpointsData(watchMax: 280, mobileMax: 640);
      const b = DeviceBreakpointsData(watchMax: 280, mobileMax: 640);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('different breakpoints are not equal', () {
      const a = DeviceBreakpointsData();
      const b = DeviceBreakpointsData(mobileMax: 640);

      expect(a, isNot(b));
    });

    test('different strategies make breakpoints not equal', () {
      const a = DeviceBreakpointsData();
      const b = DeviceBreakpointsData(strategy: StrictTabletStrategy());

      expect(a, isNot(b));
    });
  });

  group('DeviceBreakpoints.classify', () {
    test('delegates to strategy', () {
      const breakpoints = DeviceBreakpointsData();

      expect(
        breakpoints.classify(const Size(200, 300)),
        isA<DeviceTypeWatch>(),
      );
      expect(
        breakpoints.classify(const Size(400, 700)),
        isA<DeviceTypeMobile>(),
      );
      expect(
        breakpoints.classify(const Size(800, 1200)),
        isA<DeviceTypeTablet>(),
      );
      expect(
        breakpoints.classify(const Size(1200, 1600)),
        isA<DeviceTypeLargeScreen>(),
      );
    });

    test('uses custom strategy', () {
      const standard = DeviceBreakpointsData();
      const strict = DeviceBreakpointsData(strategy: StrictTabletStrategy());

      // A size that gives different results with different strategies
      // 1400x800 in landscape with longest side >= 1366
      const size = Size(1400, 800);

      expect(standard.classify(size), isA<DeviceTypeTablet>());
      expect(strict.classify(size), isA<DeviceTypeLargeScreen>());
    });
  });
}
