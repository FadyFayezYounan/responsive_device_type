import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_device_type/responsive_device_type.dart';

void main() {
  group('DeviceType sealed classes', () {
    test('DeviceTypeWatch properties', () {
      const type = DeviceTypeWatch();

      expect(type.isWatch, isTrue);
      expect(type.isMobile, isFalse);
      expect(type.isTablet, isFalse);
      expect(type.isLargeScreen, isFalse);
      expect(type.isCompact, isTrue);
      expect(type.isExpanded, isFalse);
      expect(type.name, 'watch');
      expect(type.toSimpleString(), 'watch');
      expect(type.toString(), 'DeviceType.watch');
    });

    test('DeviceTypeMobile properties', () {
      const type = DeviceTypeMobile();

      expect(type.isWatch, isFalse);
      expect(type.isMobile, isTrue);
      expect(type.isTablet, isFalse);
      expect(type.isLargeScreen, isFalse);
      expect(type.isCompact, isTrue);
      expect(type.isExpanded, isFalse);
      expect(type.name, 'mobile');
      expect(type.toSimpleString(), 'mobile');
      expect(type.toString(), 'DeviceType.mobile');
    });

    test('DeviceTypeTablet properties', () {
      const type = DeviceTypeTablet();

      expect(type.isWatch, isFalse);
      expect(type.isMobile, isFalse);
      expect(type.isTablet, isTrue);
      expect(type.isLargeScreen, isFalse);
      expect(type.isCompact, isFalse);
      expect(type.isExpanded, isTrue);
      expect(type.name, 'tablet');
      expect(type.toSimpleString(), 'tablet');
      expect(type.toString(), 'DeviceType.tablet(medium)');
    });

    test('DeviceTypeLargeScreen properties', () {
      const type = DeviceTypeLargeScreen();

      expect(type.isWatch, isFalse);
      expect(type.isMobile, isFalse);
      expect(type.isTablet, isFalse);
      expect(type.isLargeScreen, isTrue);
      expect(type.isCompact, isFalse);
      expect(type.isExpanded, isTrue);
      expect(type.name, 'largeScreen');
      expect(type.toSimpleString(), 'largeScreen');
      expect(type.toString(), 'DeviceType.largeScreen');
    });
  });

  group('DeviceType equality', () {
    test('same types are equal', () {
      expect(const DeviceTypeWatch(), const DeviceTypeWatch());
      expect(const DeviceTypeMobile(), const DeviceTypeMobile());
      expect(const DeviceTypeTablet(), const DeviceTypeTablet());
      expect(const DeviceTypeLargeScreen(), const DeviceTypeLargeScreen());
    });

    test('different types are not equal', () {
      const watch = DeviceTypeWatch();
      const mobile = DeviceTypeMobile();
      const tablet = DeviceTypeTablet();
      const largeScreen = DeviceTypeLargeScreen();

      expect(watch, isNot(mobile));
      expect(watch, isNot(tablet));
      expect(watch, isNot(largeScreen));
      expect(mobile, isNot(tablet));
      expect(mobile, isNot(largeScreen));
      expect(tablet, isNot(largeScreen));
    });

    test('hashCode is consistent', () {
      expect(
        const DeviceTypeWatch().hashCode,
        const DeviceTypeWatch().hashCode,
      );
      expect(
        const DeviceTypeMobile().hashCode,
        const DeviceTypeMobile().hashCode,
      );
      expect(
        const DeviceTypeTablet().hashCode,
        const DeviceTypeTablet().hashCode,
      );
      expect(
        const DeviceTypeLargeScreen().hashCode,
        const DeviceTypeLargeScreen().hashCode,
      );
    });
  });

  group('DeviceType pattern matching', () {
    test('exhaustive pattern matching works', () {
      String classify(DeviceType type) {
        return switch (type) {
          DeviceTypeWatch() => 'watch',
          DeviceTypeMobile() => 'mobile',
          DeviceTypeTablet() => 'tablet',
          DeviceTypeLargeScreen() => 'largeScreen',
        };
      }

      expect(classify(const DeviceTypeWatch()), 'watch');
      expect(classify(const DeviceTypeMobile()), 'mobile');
      expect(classify(const DeviceTypeTablet()), 'tablet');
      expect(classify(const DeviceTypeLargeScreen()), 'largeScreen');
    });
  });

  group('DeviceType.fromSize factory', () {
    test('classifies watch correctly', () {
      final type = DeviceType.fromSize(const Size(200, 250));
      expect(type, isA<DeviceTypeWatch>());
    });

    test('classifies mobile correctly', () {
      final type = DeviceType.fromSize(const Size(393, 852));
      expect(type, isA<DeviceTypeMobile>());
    });

    test('classifies tablet correctly', () {
      final type = DeviceType.fromSize(const Size(834, 1194));
      expect(type, isA<DeviceTypeTablet>());
    });

    test('classifies large screen correctly', () {
      final type = DeviceType.fromSize(const Size(1920, 1080));
      expect(type, isA<DeviceTypeLargeScreen>());
    });

    test('uses custom breakpoints', () {
      const customBreakpoints = DeviceBreakpointsData(
        mobileMaxShortestSide: 400,
      );

      // 393 would be mobile with defaults, but watch with custom
      final defaultType = DeviceType.fromSize(const Size(350, 400));
      final customType = DeviceType.fromSize(
        const Size(350, 400),
        breakpoints: customBreakpoints,
      );

      expect(defaultType, isA<DeviceTypeMobile>());
      expect(customType, isA<DeviceTypeMobile>());

      // Now test at the boundary
      final atBoundary = DeviceType.fromSize(
        const Size(399, 500),
        breakpoints: customBreakpoints,
      );
      expect(atBoundary, isA<DeviceTypeMobile>());

      final aboveBoundary = DeviceType.fromSize(
        const Size(400, 500),
        breakpoints: customBreakpoints,
      );
      expect(aboveBoundary, isA<DeviceTypeTablet>());
    });
  });

  group('Edge cases at boundaries', () {
    test('exactly at watch boundary', () {
      // 299 should be watch
      expect(DeviceType.fromSize(const Size(299, 400)), isA<DeviceTypeWatch>());
      // 300 should be mobile
      expect(
        DeviceType.fromSize(const Size(300, 400)),
        isA<DeviceTypeMobile>(),
      );
    });

    test('exactly at mobile boundary', () {
      // 599 should be mobile
      expect(
        DeviceType.fromSize(const Size(599, 800)),
        isA<DeviceTypeMobile>(),
      );
      // 600 should be tablet
      expect(
        DeviceType.fromSize(const Size(600, 800)),
        isA<DeviceTypeTablet>(),
      );
    });

    test('exactly at tablet boundary', () {
      // 1023 should be tablet
      expect(
        DeviceType.fromSize(const Size(1023, 1200)),
        isA<DeviceTypeTablet>(),
      );
      // 1024 should be large screen
      expect(
        DeviceType.fromSize(const Size(1024, 1200)),
        isA<DeviceTypeLargeScreen>(),
      );
    });
  });

  group('Orientation handling', () {
    test('portrait and landscape give same result for phones', () {
      // Portrait phone
      final portrait = DeviceType.fromSize(const Size(393, 852));
      // Landscape phone (same dimensions swapped)
      final landscape = DeviceType.fromSize(const Size(852, 393));

      expect(portrait, isA<DeviceTypeMobile>());
      expect(landscape, isA<DeviceTypeMobile>());
    });

    test('portrait and landscape give same result for tablets', () {
      // Portrait tablet
      final portrait = DeviceType.fromSize(const Size(834, 1194));
      // Landscape tablet
      final landscape = DeviceType.fromSize(const Size(1194, 834));

      expect(portrait, isA<DeviceTypeTablet>());
      expect(landscape, isA<DeviceTypeTablet>());
    });
  });
}
