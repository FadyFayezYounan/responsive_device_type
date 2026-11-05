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
/// Each pane gets its own [MediaQuery] with the pane's laid-out size and no
/// display features, so `context.deviceType` inside a pane classifies the
/// pane, and nested [DualPaneLayout]s do not split again. Padding, view
/// padding, keyboard insets, and system gesture insets are clipped to the
/// pane, so a keyboard in the bottom pane does not shrink the top pane.
///
/// The hinge position is reported in screen coordinates. If this widget does
/// not start at the top-left corner of the screen (for example below an
/// `AppBar`), pass its offset from the screen edges as [padding].
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
  ///
  /// [EdgeInsets.left] and [EdgeInsets.top] place the hinge. The right and
  /// bottom values are used only when this widget gets unbounded
  /// constraints; otherwise its size comes from its constraints.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final fold = FoldInfo.of(context);
    final hinge = fold.bounds;
    final axis = fold.hingeAxis;
    if (!fold.isSeparating || hinge == null || axis == null) {
      return single ?? start;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final screen = mediaQuery.size;

        // This widget's bounds in screen coordinates, the space the hinge
        // position is reported in.
        final bounds = Rect.fromLTWH(
          padding.left,
          padding.top,
          constraints.hasBoundedWidth
              ? constraints.maxWidth
              : math.max(0, screen.width - padding.horizontal),
          constraints.hasBoundedHeight
              ? constraints.maxHeight
              : math.max(0, screen.height - padding.vertical),
        );

        final isRow = axis == Axis.vertical;
        final origin = isRow ? bounds.left : bounds.top;
        final extent = isRow ? bounds.width : bounds.height;
        // Where the hinge starts and ends along the main axis, clamped to
        // this widget.
        final hingeStart = ((isRow ? hinge.left : hinge.top) - origin).clamp(
          0.0,
          extent,
        );
        final hingeEnd = ((isRow ? hinge.right : hinge.bottom) - origin).clamp(
          hingeStart,
          extent,
        );

        Rect paneRect(double from, double to) => isRow
            ? Rect.fromLTRB(
                bounds.left + from,
                bounds.top,
                bounds.left + to,
                bounds.bottom,
              )
            : Rect.fromLTRB(
                bounds.left,
                bounds.top + from,
                bounds.right,
                bounds.top + to,
              );

        final firstRect = paneRect(0, hingeStart);
        final secondRect = paneRect(hingeEnd, extent);

        Widget pane(Widget child, Rect rect) {
          return SizedBox.fromSize(
            size: rect.size,
            child: MediaQuery(data: _paneData(mediaQuery, rect), child: child),
          );
        }

        final gap = hingeEnd - hingeStart;
        if (isRow) {
          final rtl = Directionality.of(context) == TextDirection.rtl;
          return Row(
            textDirection: TextDirection.ltr,
            mainAxisSize: MainAxisSize.min,
            children: [
              pane(rtl ? end : start, firstRect),
              SizedBox(width: gap),
              pane(rtl ? start : end, secondRect),
            ],
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            pane(start, firstRect),
            SizedBox(height: gap),
            pane(end, secondRect),
          ],
        );
      },
    );
  }

  /// The [MediaQueryData] for a pane occupying [rect], in screen coordinates.
  ///
  /// The size is the pane's own size, the display features are removed so
  /// nested layouts do not split again, and every inset (padding, view
  /// padding, keyboard, system gestures) keeps only the part that overlaps
  /// the pane.
  static MediaQueryData _paneData(MediaQueryData data, Rect rect) {
    final screen = data.size;
    EdgeInsets clip(EdgeInsets insets) => EdgeInsets.fromLTRB(
      math.max(0, insets.left - rect.left),
      math.max(0, insets.top - rect.top),
      math.max(0, insets.right - (screen.width - rect.right)),
      math.max(0, insets.bottom - (screen.height - rect.bottom)),
    );
    return data.copyWith(
      size: rect.size,
      displayFeatures: const [],
      padding: clip(data.padding),
      viewPadding: clip(data.viewPadding),
      viewInsets: clip(data.viewInsets),
      systemGestureInsets: clip(data.systemGestureInsets),
    );
  }
}
