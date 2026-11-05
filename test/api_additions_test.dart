import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_device_type/responsive_device_type.dart';

class _LongestSideStrategy extends ClassificationStrategy {
  const _LongestSideStrategy();

  @override
  DeviceType classify(Size size, DeviceBreakpointsData breakpoints) =>
      classifyExtent(size.longestSide, breakpoints);
}

class _OtherStrategy extends ClassificationStrategy {
  const _OtherStrategy();

  @override
  DeviceType classify(Size size, DeviceBreakpointsData breakpoints) =>
      classifyExtent(size.width, breakpoints);
}

void main() {
  group('WindowWidthStrategy', () {
    const breakpoints = DeviceBreakpointsData(strategy: WindowWidthStrategy());

    test('uses width, so rotation changes the result', () {
      expect(
        breakpoints.classify(const Size(393, 852)),
        isA<DeviceTypeMobile>(),
      );
      expect(
        breakpoints.classify(const Size(852, 393)),
        isA<DeviceTypeTablet>(),
      );
    });

    test('a short-height laptop window is a large screen', () {
      expect(
        breakpoints.classify(const Size(1366, 768)),
        isA<DeviceTypeLargeScreen>(),
      );
    });

    test('classifies tablet sizes by width', () {
      expect(
        breakpoints.classify(const Size(650, 2000)),
        const DeviceType.tablet(size: TabletSize.small()),
      );
    });
  });

  group('ClassificationStrategy', () {
    test('custom strategies can reuse classifyExtent', () {
      const breakpoints = DeviceBreakpointsData(
        strategy: _LongestSideStrategy(),
      );
      expect(
        breakpoints.classify(const Size(200, 700)),
        isA<DeviceTypeTablet>(),
      );
    });

    test('equality is by runtime type', () {
      expect(const _LongestSideStrategy(), const _LongestSideStrategy());
      expect(const _LongestSideStrategy(), isNot(const _OtherStrategy()));
      expect(const _OtherStrategy(), isNot(const StandardStrategy()));
      expect(const WindowWidthStrategy(), const WindowWidthStrategy());
      expect(const WindowWidthStrategy(), isNot(const StandardStrategy()));
    });

    test('StrictTabletStrategy treats a MacBook window as a large screen', () {
      const breakpoints = DeviceBreakpointsData(
        strategy: StrictTabletStrategy(),
      );
      expect(
        breakpoints.classify(const Size(1512, 982)),
        isA<DeviceTypeLargeScreen>(),
      );
      // Portrait with the same sides stays a tablet.
      expect(
        breakpoints.classify(const Size(982, 1512)),
        isA<DeviceTypeTablet>(),
      );
    });
  });

  group('DeviceType ordering', () {
    const watch = DeviceType.watch();
    const mobile = DeviceType.mobile();
    const tablet = DeviceType.tablet();
    const large = DeviceType.largeScreen();

    test('isAtLeast', () {
      expect(tablet.isAtLeast(mobile), isTrue);
      expect(tablet.isAtLeast(tablet), isTrue);
      expect(mobile.isAtLeast(tablet), isFalse);
      expect(large.isAtLeast(watch), isTrue);
    });

    test('isAtMost', () {
      expect(mobile.isAtMost(tablet), isTrue);
      expect(large.isAtMost(tablet), isFalse);
      expect(watch.isAtMost(watch), isTrue);
    });

    test('ignores tablet size', () {
      const small = DeviceType.tablet(size: TabletSize.small());
      const bigTablet = DeviceType.tablet(size: TabletSize.large());
      expect(small.isAtLeast(bigTablet), isTrue);
      expect(small.isAtMost(bigTablet), isTrue);
    });
  });

  group('DeviceType.select', () {
    test('uses the exact value when present', () {
      const tablet = DeviceType.tablet();
      expect(tablet.select(mobile: 1, watch: 0, tablet: 2, largeScreen: 3), 2);
    });

    test('falls back mobile-first', () {
      expect(const DeviceType.watch().select(mobile: 1), 1);
      expect(const DeviceType.tablet().select(mobile: 1), 1);
      expect(const DeviceType.largeScreen().select(mobile: 1, tablet: 2), 2);
      expect(const DeviceType.largeScreen().select(mobile: 1), 1);
    });
  });

  group('TabletBreakpoints', () {
    test('defaults put common iPads in medium', () {
      const b = TabletBreakpoints.defaults();
      expect(b.classify(744), const TabletSize.medium()); // iPad mini
      expect(b.classify(820), const TabletSize.medium()); // iPad
      expect(b.classify(834), const TabletSize.medium()); // iPad Pro 11"
    });

    test('compact splits iPad mini from larger iPads', () {
      const b = TabletBreakpoints.compact();
      expect(b.classify(744), const TabletSize.medium());
      expect(b.classify(820), const TabletSize.large());
    });

    test('asserts', () {
      expect(
        () => TabletBreakpoints(smallMax: 0, mediumMax: 10),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => TabletBreakpoints(smallMax: 900, mediumMax: 800),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('BuildContext extensions', () {
    Future<BuildContext> pumpAt(WidgetTester tester, Size size) async {
      late BuildContext captured;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(size: size),
          child: Builder(
            builder: (context) {
              captured = context;
              return const SizedBox();
            },
          ),
        ),
      );
      return captured;
    }

    testWidgets('mobile', (tester) async {
      final context = await pumpAt(tester, const Size(393, 852));
      expect(context.deviceType, isA<DeviceTypeMobile>());
      expect(context.isMobile, isTrue);
      expect(context.isCompact, isTrue);
      expect(context.isExpanded, isFalse);
      expect(
        context.isWatch || context.isTablet || context.isLargeScreen,
        isFalse,
      );
      expect(context.deviceBreakpoints, const DeviceBreakpointsData());
      expect(context.foldInfo.hasFold, isFalse);
      expect(context.responsive(mobile: 'm', tablet: 't'), 'm');
    });

    testWidgets('tablet', (tester) async {
      final context = await pumpAt(tester, const Size(834, 1194));
      expect(context.isTablet, isTrue);
      expect(context.isExpanded, isTrue);
      expect(context.responsive(mobile: 'm', tablet: 't'), 't');
    });
  });

  group('Fallback widgets', () {
    Widget at(Size size, Widget child) => Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: MediaQueryData(size: size),
        child: child,
      ),
    );

    testWidgets('ResponsiveLayout falls back mobile-first', (tester) async {
      await tester.pumpWidget(
        at(
          const Size(1920, 1080),
          const ResponsiveLayout(
            mobile: Text('mobile'),
            tablet: Text('tablet'),
          ),
        ),
      );
      expect(find.text('tablet'), findsOneWidget);

      await tester.pumpWidget(
        at(
          const Size(200, 200),
          const ResponsiveLayout(mobile: Text('mobile')),
        ),
      );
      expect(find.text('mobile'), findsOneWidget);
    });

    testWidgets('ResponsiveValue falls back mobile-first', (tester) async {
      await tester.pumpWidget(
        at(
          const Size(834, 1194),
          ResponsiveValue<String>(
            mobile: 'mobile',
            builder: (context, value) => Text(value),
          ),
        ),
      );
      expect(find.text('mobile'), findsOneWidget);
    });

    testWidgets('DeviceTypeSwitcher only runs the selected builder', (
      tester,
    ) async {
      var mobileBuilds = 0;
      await tester.pumpWidget(
        at(
          const Size(1920, 1080),
          DeviceTypeSwitcher(
            mobile: (context) {
              mobileBuilds++;
              return const Text('mobile');
            },
            largeScreen: (context) => const Text('large'),
          ),
        ),
      );
      expect(find.text('large'), findsOneWidget);
      expect(mobileBuilds, 0);
    });

    testWidgets('DeviceTypeVisibility named constructors', (tester) async {
      await tester.pumpWidget(
        at(
          const Size(1920, 1080),
          const Column(
            children: [
              DeviceTypeVisibility.largeScreen(child: Text('large')),
              DeviceTypeVisibility.mobile(
                replacement: Text('replacement'),
                child: Text('mobile'),
              ),
            ],
          ),
        ),
      );
      expect(find.text('large'), findsOneWidget);
      expect(find.text('mobile'), findsNothing);
      expect(find.text('replacement'), findsOneWidget);
    });
  });
}
