import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_device_type/responsive_device_type.dart';

void main() {
  group('StandardStrategy', () {
    const strategy = StandardStrategy();
    const breakpoints = DeviceBreakpointsData();

    test('classifies watch', () {
      expect(
        strategy.classify(const Size(200, 250), breakpoints),
        isA<DeviceTypeWatch>(),
      );
      expect(
        strategy.classify(const Size(299, 400), breakpoints),
        isA<DeviceTypeWatch>(),
      );
    });

    test('classifies mobile', () {
      expect(
        strategy.classify(const Size(300, 500), breakpoints),
        isA<DeviceTypeMobile>(),
      );
      expect(
        strategy.classify(const Size(393, 852), breakpoints),
        isA<DeviceTypeMobile>(),
      );
      expect(
        strategy.classify(const Size(599, 800), breakpoints),
        isA<DeviceTypeMobile>(),
      );
    });

    test('classifies tablet', () {
      expect(
        strategy.classify(const Size(600, 800), breakpoints),
        isA<DeviceTypeTablet>(),
      );
      expect(
        strategy.classify(const Size(834, 1194), breakpoints),
        isA<DeviceTypeTablet>(),
      );
      expect(
        strategy.classify(const Size(1023, 1200), breakpoints),
        isA<DeviceTypeTablet>(),
      );
    });

    test('classifies large screen', () {
      expect(
        strategy.classify(const Size(1024, 1200), breakpoints),
        isA<DeviceTypeLargeScreen>(),
      );
      expect(
        strategy.classify(const Size(1920, 1080), breakpoints),
        isA<DeviceTypeLargeScreen>(),
      );
    });

    test('orientation does not affect classification', () {
      // Portrait
      expect(
        strategy.classify(const Size(393, 852), breakpoints),
        isA<DeviceTypeMobile>(),
      );
      // Landscape (same device)
      expect(
        strategy.classify(const Size(852, 393), breakpoints),
        isA<DeviceTypeMobile>(),
      );
    });

    test('equality', () {
      expect(const StandardStrategy(), const StandardStrategy());
      expect(
        const StandardStrategy().hashCode,
        const StandardStrategy().hashCode,
      );
    });

    test('toString', () {
      expect(const StandardStrategy().toString(), 'StandardStrategy()');
    });
  });

  group('StrictTabletStrategy', () {
    const strategy = StrictTabletStrategy();
    const breakpoints = DeviceBreakpointsData(strategy: strategy);

    test('classifies watch same as standard', () {
      expect(
        strategy.classify(const Size(200, 250), breakpoints),
        isA<DeviceTypeWatch>(),
      );
    });

    test('classifies mobile same as standard', () {
      expect(
        strategy.classify(const Size(393, 852), breakpoints),
        isA<DeviceTypeMobile>(),
      );
    });

    test('classifies tablet in portrait', () {
      // Portrait tablet - height > width
      expect(
        strategy.classify(const Size(834, 1194), breakpoints),
        isA<DeviceTypeTablet>(),
      );
    });

    test('classifies tablet in landscape when longest side < threshold', () {
      // Landscape tablet with longest side < 1366
      expect(
        strategy.classify(const Size(1194, 834), breakpoints),
        isA<DeviceTypeTablet>(),
      );
    });

    test(
      'classifies as large screen in landscape when longest side >= threshold',
      () {
        // Landscape with longest side >= 1366
        expect(
          strategy.classify(const Size(1400, 800), breakpoints),
          isA<DeviceTypeLargeScreen>(),
        );
        expect(
          strategy.classify(const Size(1366, 800), breakpoints),
          isA<DeviceTypeLargeScreen>(),
        );
      },
    );

    test('classifies actual large screen same as standard', () {
      expect(
        strategy.classify(const Size(1920, 1080), breakpoints),
        isA<DeviceTypeLargeScreen>(),
      );
    });

    test('custom threshold', () {
      const customStrategy = StrictTabletStrategy(
        landscapeLongestSideThreshold: 1200,
      );
      const customBreakpoints = DeviceBreakpointsData(strategy: customStrategy);

      // With threshold at 1200, 1300x800 should be large screen
      expect(
        customStrategy.classify(const Size(1300, 800), customBreakpoints),
        isA<DeviceTypeLargeScreen>(),
      );

      // But 1100x800 should still be tablet
      expect(
        customStrategy.classify(const Size(1100, 800), customBreakpoints),
        isA<DeviceTypeTablet>(),
      );
    });

    test('threshold must be positive', () {
      expect(
        () => StrictTabletStrategy(landscapeLongestSideThreshold: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => StrictTabletStrategy(landscapeLongestSideThreshold: -100),
        throwsA(isA<AssertionError>()),
      );
    });

    test('equality', () {
      expect(const StrictTabletStrategy(), const StrictTabletStrategy());
      expect(
        const StrictTabletStrategy(landscapeLongestSideThreshold: 1400),
        const StrictTabletStrategy(landscapeLongestSideThreshold: 1400),
      );
      expect(
        const StrictTabletStrategy(landscapeLongestSideThreshold: 1400),
        isNot(const StrictTabletStrategy(landscapeLongestSideThreshold: 1200)),
      );
    });

    test('hashCode', () {
      expect(
        const StrictTabletStrategy().hashCode,
        const StrictTabletStrategy().hashCode,
      );
      expect(
        const StrictTabletStrategy(
          landscapeLongestSideThreshold: 1400,
        ).hashCode,
        const StrictTabletStrategy(
          landscapeLongestSideThreshold: 1400,
        ).hashCode,
      );
    });

    test('toString', () {
      expect(
        const StrictTabletStrategy().toString(),
        'StrictTabletStrategy(landscapeLongestSideThreshold: 1366.0)',
      );
      expect(
        const StrictTabletStrategy(
          landscapeLongestSideThreshold: 1400,
        ).toString(),
        'StrictTabletStrategy(landscapeLongestSideThreshold: 1400.0)',
      );
    });
  });

  group('Strategy comparison', () {
    const standard = StandardStrategy();
    const strict = StrictTabletStrategy();
    const breakpoints = DeviceBreakpointsData();

    test('same results for clear-cut cases', () {
      // Watch
      expect(
        standard.classify(const Size(200, 250), breakpoints),
        strict.classify(const Size(200, 250), breakpoints),
      );

      // Mobile
      expect(
        standard.classify(const Size(393, 852), breakpoints),
        strict.classify(const Size(393, 852), breakpoints),
      );

      // Unambiguous large screen
      expect(
        standard.classify(const Size(1920, 1080), breakpoints),
        strict.classify(const Size(1920, 1080), breakpoints),
      );
    });

    test('different results for ambiguous desktop windows', () {
      // A desktop window sized to look like a tablet in landscape
      const size = Size(1400, 800);

      final standardResult = standard.classify(size, breakpoints);
      final strictResult = strict.classify(size, breakpoints);

      expect(standardResult, isA<DeviceTypeTablet>());
      expect(strictResult, isA<DeviceTypeLargeScreen>());
    });
  });
}
