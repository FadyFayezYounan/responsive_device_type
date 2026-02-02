import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_device_type/responsive_device_type.dart';

void main() {
  group('DeviceBreakpoints constructor', () {
    test('default values', () {
      const breakpoints = DeviceBreakpointsData();

      expect(breakpoints.watchMaxShortestSide, 300);
      expect(breakpoints.mobileMaxShortestSide, 600);
      expect(breakpoints.tabletMaxShortestSide, 1024);
      expect(breakpoints.strategy, isA<StandardStrategy>());
    });

    test('custom values', () {
      const breakpoints = DeviceBreakpointsData(
        watchMaxShortestSide: 280,
        mobileMaxShortestSide: 640,
        tabletMaxShortestSide: 1100,
        strategy: StrictTabletStrategy(),
      );

      expect(breakpoints.watchMaxShortestSide, 280);
      expect(breakpoints.mobileMaxShortestSide, 640);
      expect(breakpoints.tabletMaxShortestSide, 1100);
      expect(breakpoints.strategy, isA<StrictTabletStrategy>());
    });
  });

  group('DeviceBreakpoints.defaults', () {
    test('has correct default values', () {
      const breakpoints = DeviceBreakpointsData.defaults();

      expect(breakpoints.watchMaxShortestSide, 300);
      expect(breakpoints.mobileMaxShortestSide, 600);
      expect(breakpoints.tabletMaxShortestSide, 1024);
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

      expect(breakpoints.watchMaxShortestSide, 300);
      expect(breakpoints.mobileMaxShortestSide, 600);
      expect(breakpoints.tabletMaxShortestSide, 840);
      expect(breakpoints.strategy, isA<StandardStrategy>());
    });
  });

  group('DeviceBreakpoints assertions', () {
    test('watchMaxShortestSide must be positive', () {
      expect(
        () => DeviceBreakpointsData(watchMaxShortestSide: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => DeviceBreakpointsData(watchMaxShortestSide: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('mobileMaxShortestSide must be positive', () {
      expect(
        () => DeviceBreakpointsData(mobileMaxShortestSide: 0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('tabletMaxShortestSide must be positive', () {
      expect(
        () => DeviceBreakpointsData(tabletMaxShortestSide: 0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('values must be in ascending order', () {
      // watch >= mobile
      expect(
        () => DeviceBreakpointsData(
          watchMaxShortestSide: 600,
        ),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => DeviceBreakpointsData(
          watchMaxShortestSide: 700,
        ),
        throwsA(isA<AssertionError>()),
      );

      // mobile >= tablet
      expect(
        () => DeviceBreakpointsData(
          mobileMaxShortestSide: 1024,
        ),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => DeviceBreakpointsData(
          mobileMaxShortestSide: 1100,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('DeviceBreakpoints.copyWith', () {
    test('copies with new values', () {
      const original = DeviceBreakpointsData();
      final copied = original.copyWith(
        mobileMaxShortestSide: 640,
        strategy: const StrictTabletStrategy(),
      );

      expect(copied.watchMaxShortestSide, 300); // unchanged
      expect(copied.mobileMaxShortestSide, 640); // changed
      expect(copied.tabletMaxShortestSide, 1024); // unchanged
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
      const a = DeviceBreakpointsData(
        watchMaxShortestSide: 280,
        mobileMaxShortestSide: 640,
      );
      const b = DeviceBreakpointsData(
        watchMaxShortestSide: 280,
        mobileMaxShortestSide: 640,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('different breakpoints are not equal', () {
      const a = DeviceBreakpointsData();
      const b = DeviceBreakpointsData(mobileMaxShortestSide: 640);

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
