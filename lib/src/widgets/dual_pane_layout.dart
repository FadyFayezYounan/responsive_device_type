import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:responsive_device_type/src/models/fold_info.dart';

/// Lays out two widgets on either side of a separating fold or hinge.
///
/// When [FoldInfo.isSeparating] is true (a dual-screen device, or a foldable
/// that is half-open), [start] and [end] are placed in the two regions
/// around the hinge, and nothing is drawn under it:
///
/// * Vertical hinge (book): [start] on the leading side, [end] on the
///   trailing side. Respects [Directionality].
/// * Horizontal hinge (tabletop): [start] on top, [end] on the bottom.
///
/// Otherwise (no fold, or a foldable lying flat) [single] is shown, or
/// [start] when [single] is null.
///
/// Each pane gets its own [MediaQuery] with the pane's size and no display
/// features, so `context.deviceType` inside a pane classifies the pane, and
/// nested [DualPaneLayout]s do not split again.
///
/// The hinge position is reported in screen coordinates, so this widget
/// assumes it covers the whole screen. If it does not (for example below an
/// `AppBar`), pass the space between the screen edges and this widget as
/// [padding].
///
/// ```dart
/// DualPaneLayout(
///   start: const InboxList(),
///   end: const MessageDetail(),
///   single: const InboxWithNavigation(),
/// )
/// ```
class DualPaneLayout extends StatelessWidget {
  /// Creates a [DualPaneLayout].
  const DualPaneLayout({
    required this.start,
    required this.end,
    this.single,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  /// Shown in the leading (book) or top (tabletop) pane.
  final Widget start;

  /// Shown in the trailing (book) or bottom (tabletop) pane.
  final Widget end;

  /// Shown when the fold is not separating. Defaults to [start].
  final Widget? single;

  /// Distance between the screen edges and this widget's edges.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final fold = FoldInfo.of(context);
    final mediaQuery = MediaQuery.of(context);
    final panes = fold.isSeparating ? fold.panes(mediaQuery.size) : null;
    final hinge = fold.bounds;
    if (panes == null || hinge == null) return single ?? start;

    final (first, second) = panes;
    final isRow = fold.hingeAxis == Axis.vertical;
    final firstExtent = math
        .max(0, isRow ? first.width - padding.left : first.height - padding.top)
        .toDouble();
    final gap = isRow ? hinge.width : hinge.height;

    Widget pane(Widget child, Rect rect, EdgeInsets removeSides) {
      return MediaQuery(
        data: mediaQuery.copyWith(
          size: rect.size,
          displayFeatures: const [],
          padding: _without(mediaQuery.padding, removeSides),
          viewPadding: _without(mediaQuery.viewPadding, removeSides),
        ),
        child: child,
      );
    }

    if (isRow) {
      final rtl = Directionality.of(context) == TextDirection.rtl;
      final leftChild = rtl ? end : start;
      final rightChild = rtl ? start : end;
      return Row(
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: firstExtent,
            child: pane(leftChild, first, const EdgeInsets.only(right: 1)),
          ),
          SizedBox(width: gap),
          Expanded(
            child: pane(rightChild, second, const EdgeInsets.only(left: 1)),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: firstExtent,
          child: pane(start, first, const EdgeInsets.only(bottom: 1)),
        ),
        SizedBox(height: gap),
        Expanded(child: pane(end, second, const EdgeInsets.only(top: 1))),
      ],
    );
  }

  /// Zeroes the sides of [insets] that are non-zero in [sides].
  static EdgeInsets _without(EdgeInsets insets, EdgeInsets sides) {
    return EdgeInsets.fromLTRB(
      sides.left > 0 ? 0 : insets.left,
      sides.top > 0 ? 0 : insets.top,
      sides.right > 0 ? 0 : insets.right,
      sides.bottom > 0 ? 0 : insets.bottom,
    );
  }
}
