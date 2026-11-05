// Explicit tablet sizes keep the sequences readable.
// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_device_type/responsive_device_type.dart';

const _watch = DeviceType.watch();
const _mobile = DeviceType.mobile();
const _small = DeviceType.tablet(size: TabletSize.small());
const _medium = DeviceType.tablet(size: TabletSize.medium());
const _large = DeviceType.tablet(size: TabletSize.large());
const _largeScreen = DeviceType.largeScreen();

/// Pumps the same tree with each size in turn and returns the device type
/// seen by `context.deviceType` after each step.
Future<List<DeviceType>> _replay(
  WidgetTester tester,
  List<Size> sizes, {
  DeviceBreakpointsData breakpoints = const DeviceBreakpointsData(),
}) async {
  final seen = <DeviceType>[];
  for (final size in sizes) {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: size),
        child: DeviceBreakpoints(
          breakpoints: breakpoints,
          child: Builder(
            builder: (context) {
              seen.add(context.deviceType);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
  // One entry per step: a build per size change, none extra.
  expect(seen, hasLength(sizes.length));
  return seen;
}

void main() {
  group('rotation', () {
    const phone = Size(393, 852);
    const ipadMini = Size(744, 1133);

    testWidgets('shortest side: rotating keeps the type', (tester) async {
      final seen = await _replay(tester, [
        phone,
        phone.flipped,
        phone,
        ipadMini,
        ipadMini.flipped,
      ]);
      expect(seen, [_mobile, _mobile, _mobile, _medium, _medium]);
    });

    testWidgets('width: rotating follows the width', (tester) async {
      final seen = await _replay(
        tester,
        [phone, phone.flipped, ipadMini, ipadMini.flipped],
        breakpoints: const DeviceBreakpointsData(
          strategy: WindowWidthStrategy(),
        ),
      );
      expect(seen, [_mobile, _medium, _medium, _largeScreen]);
    });

    testWidgets('Material 3: a landscape phone is expanded', (tester) async {
      final seen = await _replay(tester, [
        phone,
        phone.flipped,
      ], breakpoints: const DeviceBreakpointsData.material3());
      expect(seen, [_mobile, _largeScreen]);
    });

    testWidgets('strict: only a big landscape tablet is promoted', (
      tester,
    ) async {
      final seen = await _replay(
        tester,
        [
          const Size(1024, 1366),
          const Size(900, 1400),
          const Size(1400, 900),
          const Size(834, 1194),
          const Size(1194, 834),
        ],
        breakpoints: const DeviceBreakpointsData(
          strategy: StrictTabletStrategy(),
        ),
      );
      expect(seen, [_largeScreen, _large, _largeScreen, _medium, _medium]);
    });
  });

  group('desktop resizing', () {
    // Shrinking a 900-tall window from full width to a narrow strip.
    final shrinking = [
      for (final w in const <double>[1440, 1023, 899, 719, 599, 299])
        Size(w, 900),
    ];

    testWidgets('width: steps through every type and back', (tester) async {
      final seen = await _replay(
        tester,
        [...shrinking, ...shrinking.reversed],
        breakpoints: const DeviceBreakpointsData(
          strategy: WindowWidthStrategy(),
        ),
      );
      const down = [_largeScreen, _large, _medium, _small, _mobile, _watch];
      expect(seen, [...down, ...down.reversed]);
    });

    testWidgets('shortest side: a wide window is limited by its height', (
      tester,
    ) async {
      final seen = await _replay(tester, shrinking);
      expect(seen, [_large, _large, _medium, _small, _mobile, _watch]);
    });
  });

  group('foldables', () {
    const zFoldCover = Size(344, 882);
    const zFoldMain = Size(673, 841);
    const pixelFoldMain = Size(841, 701);

    testWidgets('fold and unfold switch mobile and tablet', (tester) async {
      final seen = await _replay(tester, [
        zFoldCover,
        zFoldMain,
        zFoldMain.flipped,
        zFoldCover,
      ]);
      expect(seen, [_mobile, _small, _small, _mobile]);
    });

    testWidgets('width: an unfolded landscape screen is a larger tablet', (
      tester,
    ) async {
      final seen = await _replay(
        tester,
        [zFoldCover, pixelFoldMain, pixelFoldMain.flipped],
        breakpoints: const DeviceBreakpointsData(
          strategy: WindowWidthStrategy(),
        ),
      );
      expect(seen, [_mobile, _medium, _small]);
    });
  });

  group('breakpoints changing at runtime', () {
    testWidgets('dependents rebuild with the new breakpoints', (tester) async {
      final seen = <DeviceType?>[];

      Future<void> pump(DeviceBreakpointsData breakpoints) {
        return tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(620, 900)),
            child: DeviceBreakpoints(
              breakpoints: breakpoints,
              child: Builder(
                builder: (context) {
                  seen.add(DeviceBreakpoints.maybeDeviceTypeOf(context));
                  return const SizedBox();
                },
              ),
            ),
          ),
        );
      }

      await pump(const DeviceBreakpointsData());
      await pump(const DeviceBreakpointsData(mobileMax: 700));
      await pump(const DeviceBreakpointsData(mobileMax: 700));
      expect(seen.first, _small);
      expect(seen.last, _mobile);
    });
  });
}
