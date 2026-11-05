import 'dart:ui';

import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ResponsiveDeviceTypeExampleApp());
  }

  testWidgets('phone uses bottom navigation', (tester) async {
    await pumpAt(tester, const Size(393, 852));
    expect(find.text('Current device: mobile'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('desktop uses a navigation rail', (tester) async {
    await pumpAt(tester, const Size(1280, 800));
    expect(find.text('Current device: largeScreen'), findsOneWidget);
    expect(find.byType(NavigationRail), findsOneWidget);
  });

  testWidgets('dual-screen device shows two panes', (tester) async {
    tester.view.displayFeatures = const [
      DisplayFeature(
        bounds: Rect.fromLTWH(540, 0, 34, 720),
        type: DisplayFeatureType.hinge,
        state: DisplayFeatureState.postureFlat,
      ),
    ];
    await pumpAt(tester, const Size(1114, 720));
    expect(find.text('Fold'), findsOneWidget);
    expect(find.textContaining('Separating: true'), findsWidgets);
  });
}
