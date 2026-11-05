// Explicit tablet sizes keep the cases readable.
// ignore_for_file: avoid_redundant_argument_values

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_device_type/responsive_device_type.dart';

void main() {
  group('DeviceType callbacks', () {
    const cases = <(DeviceType, String)>[
      (DeviceType.watch(), 'watch'),
      (DeviceType.mobile(), 'mobile'),
      (DeviceType.tablet(size: TabletSize.large()), 'tablet:large'),
      (DeviceType.largeScreen(), 'largeScreen'),
    ];

    for (final (type, label) in cases) {
      group(type.name, () {
        test('when / maybeWhen / whenOrNull', () {
          expect(
            type.when(
              watch: () => 'watch',
              mobile: () => 'mobile',
              tablet: (size) => 'tablet:${size.name}',
              largeScreen: () => 'largeScreen',
            ),
            label,
          );
          expect(
            type.maybeWhen(
              orElse: () => 'else',
              watch: () => 'watch',
              mobile: () => 'mobile',
              tablet: (size) => 'tablet:${size.name}',
              largeScreen: () => 'largeScreen',
            ),
            label,
          );
          expect(type.maybeWhen(orElse: () => 'else'), 'else');
          expect(
            type.whenOrNull(
              watch: () => 'watch',
              mobile: () => 'mobile',
              tablet: (size) => 'tablet:${size.name}',
              largeScreen: () => 'largeScreen',
            ),
            label,
          );
          expect(type.whenOrNull<String>(), isNull);
        });

        test('map / maybeMap / mapOrNull pass the instance', () {
          expect(
            type.map(
              watch: (t) => t,
              mobile: (t) => t,
              tablet: (t) => t,
              largeScreen: (t) => t,
            ),
            same(type),
          );
          expect(
            type.maybeMap(
              orElse: (t) => throw StateError('unreachable'),
              watch: (t) => t,
              mobile: (t) => t,
              tablet: (t) => t,
              largeScreen: (t) => t,
            ),
            same(type),
          );
          expect(type.maybeMap(orElse: (t) => t), same(type));
          expect(
            type.mapOrNull(
              watch: (t) => t,
              mobile: (t) => t,
              tablet: (t) => t,
              largeScreen: (t) => t,
            ),
            same(type),
          );
          expect(type.mapOrNull<Object>(), isNull);
        });

        test('name, toSimpleString, toString', () {
          expect(type.toSimpleString(), type.name);
          expect(type.toString(), startsWith('DeviceType.${type.name}'));
        });
      });
    }

    test('tablet size flags', () {
      const small = DeviceTypeTablet(size: TabletSize.small());
      const medium = DeviceTypeTablet(size: TabletSize.medium());
      const large = DeviceTypeTablet(size: TabletSize.large());
      expect(
        [small.isSmallTablet, small.isMediumTablet, small.isLargeTablet],
        [true, false, false],
      );
      expect(
        [medium.isSmallTablet, medium.isMediumTablet, medium.isLargeTablet],
        [false, true, false],
      );
      expect(
        [large.isSmallTablet, large.isMediumTablet, large.isLargeTablet],
        [false, false, true],
      );
      expect(large.toString(), 'DeviceType.tablet(large)');
    });
  });

  group('DeviceType.fromWidth', () {
    test('uses the width with the given breakpoints', () {
      expect(DeviceType.fromWidth(393), const DeviceType.mobile());
      expect(DeviceType.fromWidth(1366), const DeviceType.largeScreen());
      expect(
        DeviceType.fromWidth(
          700,
          breakpoints: const DeviceBreakpointsData(mobileMax: 701),
        ),
        const DeviceType.mobile(),
      );
    });
  });

  group('TabletSize', () {
    const cases = <(TabletSize, String, List<bool>)>[
      (TabletSize.small(), 'small', [true, false, false]),
      (TabletSize.medium(), 'medium', [false, true, false]),
      (TabletSize.large(), 'large', [false, false, true]),
    ];

    for (final (size, name, flags) in cases) {
      group(name, () {
        test('flags, name, toString', () {
          expect([size.isSmall, size.isMedium, size.isLarge], flags);
          expect(size.name, name);
          expect(size.toSimpleString(), name);
          expect(size.toString(), 'TabletSize.$name');
        });

        test('equality and hashCode', () {
          for (final (other, otherName, _) in cases) {
            expect(size == other, name == otherName);
          }
          expect(size.hashCode, name.hashCode);
        });

        test('when / maybeWhen / whenOrNull', () {
          expect(
            size.when(
              small: () => 'small',
              medium: () => 'medium',
              large: () => 'large',
            ),
            name,
          );
          expect(
            size.maybeWhen(
              orElse: () => 'else',
              small: () => 'small',
              medium: () => 'medium',
              large: () => 'large',
            ),
            name,
          );
          expect(size.maybeWhen(orElse: () => 'else'), 'else');
          expect(
            size.whenOrNull(
              small: () => 'small',
              medium: () => 'medium',
              large: () => 'large',
            ),
            name,
          );
          expect(size.whenOrNull<String>(), isNull);
        });

        test('map / maybeMap / mapOrNull pass the instance', () {
          expect(
            size.map(small: (s) => s, medium: (s) => s, large: (s) => s),
            same(size),
          );
          expect(
            size.maybeMap(
              orElse: (s) => throw StateError('unreachable'),
              small: (s) => s,
              medium: (s) => s,
              large: (s) => s,
            ),
            same(size),
          );
          expect(size.maybeMap(orElse: (s) => s), same(size));
          expect(
            size.mapOrNull(small: (s) => s, medium: (s) => s, large: (s) => s),
            same(size),
          );
          expect(size.mapOrNull<Object>(), isNull);
        });
      });
    }
  });

  group('TabletBreakpoints', () {
    test('presets', () {
      expect(
        const TabletBreakpoints.wide(),
        const TabletBreakpoints(smallMax: 768, mediumMax: 960),
      );
      expect(
        const TabletBreakpoints.compact(),
        const TabletBreakpoints(smallMax: 680, mediumMax: 800),
      );
      expect(
        const TabletBreakpoints.defaults(),
        const TabletBreakpoints(smallMax: 720, mediumMax: 900),
      );
    });

    test('equality, hashCode, toString', () {
      const a = TabletBreakpoints(smallMax: 700, mediumMax: 850);
      const b = TabletBreakpoints(smallMax: 700, mediumMax: 850);
      const c = TabletBreakpoints(smallMax: 700, mediumMax: 860);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(
        a.toString(),
        'TabletBreakpoints(smallMax: 700.0, mediumMax: 850.0)',
      );
    });
  });

  group('FoldInfo', () {
    const hinge = DisplayFeature(
      bounds: Rect.fromLTWH(540, 0, 34, 720),
      type: DisplayFeatureType.hinge,
      state: DisplayFeatureState.postureFlat,
    );

    test('equality, hashCode, toString', () {
      expect(const FoldInfo(feature: hinge), const FoldInfo(feature: hinge));
      expect(
        const FoldInfo(feature: hinge).hashCode,
        const FoldInfo(feature: hinge).hashCode,
      );
      expect(const FoldInfo(feature: hinge), isNot(const FoldInfo.none()));
      expect(const FoldInfo.none().toString(), 'FoldInfo.none()');
      expect(
        const FoldInfo(feature: hinge).toString(),
        allOf(contains('axis: vertical'), contains('separating: true')),
      );
    });

    test('a zero-size feature has no axis and no panes', () {
      const point = DisplayFeature(
        bounds: Rect.fromLTWH(100, 100, 0, 0),
        type: DisplayFeatureType.fold,
        state: DisplayFeatureState.postureHalfOpened,
      );
      const fold = FoldInfo(feature: point);
      expect(fold.hingeAxis, isNull);
      expect(fold.panes(const Size(800, 800)), isNull);
      expect(fold.isTabletop, isFalse);
      expect(fold.isBook, isFalse);
    });
  });
}
