import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_device_type/responsive_device_type.dart';

void main() {
  group('DeviceTypeBuilder', () {
    testWidgets('builds with correct device type', (tester) async {
      DeviceType? capturedType;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(393, 852)),
          child: DeviceTypeBuilder(
            builder: (context, type) {
              capturedType = type;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedType, isA<DeviceTypeMobile>());
    });

    testWidgets('rebuilds when MediaQuery changes', (tester) async {
      final capturedTypes = <DeviceType>[];

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(393, 852)),
          child: DeviceTypeBuilder(
            builder: (context, type) {
              capturedTypes.add(type);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedTypes.length, 1);
      expect(capturedTypes.first, isA<DeviceTypeMobile>());

      // Change to tablet size
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(834, 1194)),
          child: DeviceTypeBuilder(
            builder: (context, type) {
              capturedTypes.add(type);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedTypes.length, 2);
      expect(capturedTypes.last, isA<DeviceTypeTablet>());
    });

    testWidgets('uses scope breakpoints when provided', (tester) async {
      DeviceType? capturedType;

      const scopeBreakpoints = DeviceBreakpointsData(
        mobileMaxShortestSide: 500,
        tabletMaxShortestSide: 900,
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(620, 900)),
          child: DeviceBreakpoints(
            breakpoints: scopeBreakpoints,
            child: DeviceTypeBuilder(
              builder: (context, type) {
                capturedType = type;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // With scope (mobileMax = 500), 620 > 500 so it's tablet
      expect(capturedType, isA<DeviceTypeTablet>());
    });
  });

  group('Integration tests', () {
    testWidgets('responsive layout using pattern matching', (tester) async {
      String? layoutName;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(393, 852)),
          child: DeviceTypeBuilder(
            builder: (context, type) {
              layoutName = switch (type) {
                DeviceTypeWatch() => 'watch',
                DeviceTypeMobile() => 'mobile',
                DeviceTypeTablet() => 'tablet',
                DeviceTypeLargeScreen() => 'desktop',
              };
              return Text(layoutName!, textDirection: TextDirection.ltr);
            },
          ),
        ),
      );

      expect(layoutName, 'mobile');
      expect(find.text('mobile'), findsOneWidget);
    });

    testWidgets('adaptive columns using device type', (tester) async {
      int? columns;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(834, 1194)),
          child: DeviceTypeBuilder(
            builder: (context, type) {
              columns = switch (type) {
                DeviceTypeWatch() => 1,
                DeviceTypeMobile() => 2,
                DeviceTypeTablet() => 3,
                DeviceTypeLargeScreen() => 4,
              };
              return Text('$columns columns', textDirection: TextDirection.ltr);
            },
          ),
        ),
      );

      expect(columns, 3);
      expect(find.text('3 columns'), findsOneWidget);
    });
  });
}
