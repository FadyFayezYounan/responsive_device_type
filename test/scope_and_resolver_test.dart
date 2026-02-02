import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_device_type/responsive_device_type.dart';

void main() {
  group('DeviceBreakpoints', () {
    testWidgets('provides breakpoints to descendants', (tester) async {
      const customBreakpoints = DeviceBreakpointsData(
        mobileMaxShortestSide: 640,
      );

      DeviceBreakpointsData? capturedBreakpoints;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: DeviceBreakpoints(
            breakpoints: customBreakpoints,
            child: Builder(
              builder: (context) {
                capturedBreakpoints = DeviceBreakpoints.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedBreakpoints, customBreakpoints);
    });

    testWidgets('maybeOf returns default when no scope', (tester) async {
      DeviceBreakpointsData? capturedBreakpoints;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: Builder(
            builder: (context) {
              capturedBreakpoints = DeviceBreakpoints.maybeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedBreakpoints, isNull);
    });

    testWidgets('of returns default when no scope', (tester) async {
      DeviceBreakpointsData? capturedBreakpoints;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: Builder(
            builder: (context) {
              capturedBreakpoints = DeviceBreakpoints.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Should return default breakpoints, not throw
      expect(capturedBreakpoints, isNotNull);
      expect(capturedBreakpoints, const DeviceBreakpointsData());
    });

    testWidgets('nested scopes use nearest ancestor', (tester) async {
      const outerBreakpoints = DeviceBreakpointsData(
        mobileMaxShortestSide: 500,
        tabletMaxShortestSide: 900,
      );
      const innerBreakpoints = DeviceBreakpointsData(
        mobileMaxShortestSide: 640,
        tabletMaxShortestSide: 1100,
      );

      DeviceBreakpointsData? outerCaptured;
      DeviceBreakpointsData? innerCaptured;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: DeviceBreakpoints(
            breakpoints: outerBreakpoints,
            child: Column(
              children: [
                Builder(
                  builder: (context) {
                    outerCaptured = DeviceBreakpoints.of(context);
                    return const SizedBox();
                  },
                ),
                DeviceBreakpoints(
                  breakpoints: innerBreakpoints,
                  child: Builder(
                    builder: (context) {
                      innerCaptured = DeviceBreakpoints.of(context);
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(outerCaptured, outerBreakpoints);
      expect(innerCaptured, innerBreakpoints);
    });
  });

  group('DeviceBreakpoints static methods', () {
    testWidgets('deviceTypeOf returns correct device type', (tester) async {
      DeviceType? capturedType;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(393, 852)),
          child: Builder(
            builder: (context) {
              capturedType = DeviceBreakpoints.deviceTypeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedType, isA<DeviceTypeMobile>());
    });

    testWidgets('maybeDeviceTypeOf returns null when no scope', (tester) async {
      DeviceType? capturedType;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(393, 852)),
          child: Builder(
            builder: (context) {
              capturedType = DeviceBreakpoints.maybeDeviceTypeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Should return null when no DeviceBreakpoints widget exists
      expect(capturedType, isNull);
    });

    testWidgets('uses scoped breakpoints', (tester) async {
      DeviceType? capturedType;
      // 620x900 would be tablet with defaults (shortestSide = 620 >= 600)
      // But mobile with custom breakpoints (mobileMaxShortestSide = 700)
      const customBreakpoints = DeviceBreakpointsData(
        mobileMaxShortestSide: 700,
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(620, 900)),
          child: DeviceBreakpoints(
            breakpoints: customBreakpoints,
            child: Builder(
              builder: (context) {
                capturedType = DeviceBreakpoints.deviceTypeOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedType, isA<DeviceTypeMobile>());
    });

    testWidgets('falls back to defaults when no scope', (tester) async {
      DeviceType? capturedType;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(620, 900)),
          child: Builder(
            builder: (context) {
              capturedType = DeviceBreakpoints.deviceTypeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedType, isA<DeviceTypeTablet>());
    });
  });
}
