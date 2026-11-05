import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_device_type/responsive_device_type.dart';

/// Spanned dual-screen device: two 540x720 screens and a 34dp hinge.
const _duoHinge = DisplayFeature(
  bounds: Rect.fromLTWH(540, 0, 34, 720),
  type: DisplayFeatureType.hinge,
  state: DisplayFeatureState.postureFlat,
);
const _duoSize = Size(1114, 720);

/// Book-style foldable, unfolded, with a zero-width vertical fold.
DisplayFeature _bookFold(DisplayFeatureState state) => DisplayFeature(
  bounds: const Rect.fromLTWH(420, 0, 0, 900),
  type: DisplayFeatureType.fold,
  state: state,
);

/// Book-style foldable held in landscape, half-open like a laptop.
const _tabletopFold = DisplayFeature(
  bounds: Rect.fromLTWH(0, 420, 900, 0),
  type: DisplayFeatureType.fold,
  state: DisplayFeatureState.postureHalfOpened,
);

const _cutout = DisplayFeature(
  bounds: Rect.fromLTWH(180, 0, 40, 30),
  type: DisplayFeatureType.cutout,
  state: DisplayFeatureState.unknown,
);

void main() {
  group('FoldInfo', () {
    test('no features means no fold', () {
      final fold = FoldInfo.fromDisplayFeatures(const []);
      expect(fold, const FoldInfo.none());
      expect(fold.hasFold, isFalse);
      expect(fold.isSeparating, isFalse);
      expect(fold.hingeAxis, isNull);
      expect(fold.panes(const Size(400, 800)), isNull);
      expect(fold.posture, FoldPosture.flat);
    });

    test('ignores cutouts', () {
      expect(FoldInfo.fromDisplayFeatures(const [_cutout]).hasFold, isFalse);
      expect(
        FoldInfo.fromDisplayFeatures(const [_cutout, _duoHinge]).feature,
        _duoHinge,
      );
    });

    test('a physical hinge is always separating', () {
      const fold = FoldInfo(feature: _duoHinge);
      expect(fold.hasFold, isTrue);
      expect(fold.posture, FoldPosture.flat);
      expect(fold.hingeAxis, Axis.vertical);
      expect(fold.isSeparating, isTrue);
      expect(fold.isBook, isFalse);
      expect(fold.panes(_duoSize), (
        const Rect.fromLTWH(0, 0, 540, 720),
        const Rect.fromLTWH(574, 0, 540, 720),
      ));
    });

    test('a flat flexible fold is not separating', () {
      final fold = FoldInfo(
        feature: _bookFold(DisplayFeatureState.postureFlat),
      );
      expect(fold.isSeparating, isFalse);
      expect(fold.hingeAxis, Axis.vertical);
    });

    test('a half-open vertical fold is book posture', () {
      final fold = FoldInfo(
        feature: _bookFold(DisplayFeatureState.postureHalfOpened),
      );
      expect(fold.posture, FoldPosture.halfOpened);
      expect(fold.isBook, isTrue);
      expect(fold.isTabletop, isFalse);
      expect(fold.isSeparating, isTrue);
    });

    test('a half-open horizontal fold is tabletop posture', () {
      const fold = FoldInfo(feature: _tabletopFold);
      expect(fold.hingeAxis, Axis.horizontal);
      expect(fold.isTabletop, isTrue);
      expect(fold.isBook, isFalse);
      expect(fold.panes(const Size(900, 840)), (
        const Rect.fromLTWH(0, 0, 900, 420),
        const Rect.fromLTWH(0, 420, 900, 420),
      ));
    });

    test('unknown posture', () {
      const fold = FoldInfo(
        feature: DisplayFeature(
          bounds: Rect.fromLTWH(10, 0, 0, 100),
          type: DisplayFeatureType.fold,
          state: DisplayFeatureState.unknown,
        ),
      );
      expect(fold.posture, FoldPosture.unknown);
      expect(fold.isSeparating, isFalse);
    });

    testWidgets('of(context) reads MediaQuery display features', (
      tester,
    ) async {
      late FoldInfo fold;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: _duoSize,
            displayFeatures: [_duoHinge],
          ),
          child: Builder(
            builder: (context) {
              fold = context.foldInfo;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(fold.feature, _duoHinge);
    });
  });

  group('DualPaneLayout', () {
    Widget app(
      MediaQueryData data, {
      TextDirection direction = TextDirection.ltr,
      EdgeInsets padding = EdgeInsets.zero,
      Widget? single,
    }) {
      return Directionality(
        textDirection: direction,
        child: MediaQuery(
          data: data,
          child: DualPaneLayout(
            padding: padding,
            single: single,
            start: const Text('start'),
            end: Builder(
              builder: (context) => Text(
                'end ${context.deviceType.name} '
                '${MediaQuery.sizeOf(context).width.toInt()} '
                '${context.foldInfo.hasFold}',
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('shows single without a fold', (tester) async {
      await tester.pumpWidget(
        app(
          const MediaQueryData(size: Size(400, 800)),
          single: const Text('single'),
        ),
      );
      expect(find.text('single'), findsOneWidget);
      expect(find.text('start'), findsNothing);
    });

    testWidgets('falls back to start when single is null', (tester) async {
      await tester.pumpWidget(app(const MediaQueryData(size: Size(400, 800))));
      expect(find.text('start'), findsOneWidget);
    });

    testWidgets('does not split a flat flexible fold', (tester) async {
      await tester.pumpWidget(
        app(
          MediaQueryData(
            size: const Size(840, 900),
            displayFeatures: [_bookFold(DisplayFeatureState.postureFlat)],
          ),
        ),
      );
      expect(find.text('start'), findsOneWidget);
      expect(find.textContaining('end'), findsNothing);
    });

    testWidgets('splits around a hinge, panes see their own size', (
      tester,
    ) async {
      tester.view.physicalSize = _duoSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        app(const MediaQueryData(size: _duoSize, displayFeatures: [_duoHinge])),
      );

      final start = tester.getRect(find.text('start'));
      final end = tester.getRect(find.textContaining('end'));
      expect(start.left, 0);
      expect(end.left, 574);
      // Each pane is a 540x720 screen, so it classifies as mobile and no
      // longer sees the hinge.
      expect(find.text('end mobile 540 false'), findsOneWidget);
    });

    testWidgets('RTL puts start on the right', (tester) async {
      tester.view.physicalSize = _duoSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        app(
          const MediaQueryData(size: _duoSize, displayFeatures: [_duoHinge]),
          direction: TextDirection.rtl,
        ),
      );
      expect(
        tester.getRect(find.text('start')).left,
        greaterThanOrEqualTo(574),
      );
      expect(tester.getRect(find.textContaining('end')).left, lessThan(540));
    });

    testWidgets('tabletop splits top and bottom', (tester) async {
      tester.view.physicalSize = const Size(900, 840);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        app(
          const MediaQueryData(
            size: Size(900, 840),
            displayFeatures: [_tabletopFold],
          ),
        ),
      );
      expect(tester.getRect(find.text('start')).top, 0);
      expect(tester.getRect(find.textContaining('end')).top, 420);
    });

    testWidgets('padding shifts the split for widgets below the top edge', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(900, 840);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(900, 840),
              displayFeatures: [_tabletopFold],
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 56),
              child: DualPaneLayout(
                padding: const EdgeInsets.only(top: 56),
                start: const Text('start'),
                end: const Text('end'),
              ),
            ),
          ),
        ),
      );
      // The end pane still starts at the hinge in screen coordinates.
      expect(tester.getRect(find.text('end')).top, 420);
    });
  });
}
