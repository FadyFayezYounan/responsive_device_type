import 'dart:ui'
    show DisplayFeature, DisplayFeatureState, DisplayFeatureType, Rect, Size;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Axis, BuildContext, MediaQuery;

/// The physical posture of a foldable device.
enum FoldPosture {
  /// The device is fully open (or the hinge is a fixed gap, as on
  /// dual-screen devices).
  flat,

  /// The device is partially folded, for example propped up like a laptop
  /// ("tabletop") or held like a book.
  halfOpened,

  /// The platform reported a fold or hinge but no posture.
  unknown,
}

/// Information about the fold or hinge of a foldable or dual-screen device.
///
/// This is independent of [DeviceType]: the same phone is usually
/// [DeviceTypeMobile] when folded (cover screen) and [DeviceTypeTablet] when
/// unfolded. Use [DeviceType] for "how much space do I have?" and [FoldInfo]
/// for "is there a hinge I must lay out around?".
///
/// The data comes from `MediaQuery.displayFeaturesOf`, which Flutter fills
/// in on Android through Jetpack WindowManager (Galaxy Z Fold, Pixel Fold,
/// Surface Duo, and others). On platforms that do not report display
/// features, including iOS today, [hasFold] is always `false`. Size-based
/// classification still adapts when such a device folds or unfolds.
///
/// ```dart
/// final fold = context.foldInfo;
/// if (fold.isTabletop) {
///   // Video on top half, controls on the bottom half.
/// }
/// ```
///
/// See also:
///
///  * `DualPaneLayout`, which lays out two widgets around a separating hinge.
@immutable
final class FoldInfo {
  /// Creates fold information from a single fold or hinge [feature].
  ///
  /// Pass `null` for a device without a fold.
  const FoldInfo({this.feature});

  /// Fold information for a device without a fold or hinge.
  const FoldInfo.none() : feature = null;

  /// Picks the first fold or hinge from [features], ignoring cutouts.
  factory FoldInfo.fromDisplayFeatures(Iterable<DisplayFeature> features) {
    for (final f in features) {
      if (f.type == DisplayFeatureType.fold ||
          f.type == DisplayFeatureType.hinge) {
        return FoldInfo(feature: f);
      }
    }
    return const FoldInfo.none();
  }

  /// Reads fold information from the nearest [MediaQuery].
  ///
  /// The calling widget rebuilds only when the display features change.
  factory FoldInfo.of(BuildContext context) =>
      FoldInfo.fromDisplayFeatures(MediaQuery.displayFeaturesOf(context));

  /// The fold or hinge reported by the platform, in global logical pixels.
  final DisplayFeature? feature;

  /// Whether the device reports a fold or hinge in the current window.
  ///
  /// `false` on the cover screen of a folded device, because the cover
  /// screen has no fold.
  bool get hasFold => feature != null;

  /// The bounds of the fold or hinge, or `null` when there is none.
  ///
  /// A fold in a single flexible screen usually has zero thickness. A
  /// physical hinge between two screens has a non-zero thickness.
  Rect? get bounds => feature?.bounds;

  /// The posture reported for the fold.
  FoldPosture get posture => switch (feature?.state) {
    null => FoldPosture.flat,
    DisplayFeatureState.postureFlat => FoldPosture.flat,
    DisplayFeatureState.postureHalfOpened => FoldPosture.halfOpened,
    DisplayFeatureState.unknown => FoldPosture.unknown,
  };

  /// The direction the hinge runs in, or `null` when there is no fold.
  ///
  /// * [Axis.vertical]: the hinge runs top to bottom, splitting the screen
  ///   into left and right panes ("book").
  /// * [Axis.horizontal]: the hinge runs left to right, splitting the screen
  ///   into top and bottom panes ("tabletop").
  Axis? get hingeAxis {
    final b = bounds;
    if (b == null) return null;
    if (b.height > b.width) return Axis.vertical;
    if (b.width > b.height) return Axis.horizontal;
    return null;
  }

  /// Half-open with a horizontal hinge, like a laptop on a desk.
  bool get isTabletop =>
      posture == FoldPosture.halfOpened && hingeAxis == Axis.horizontal;

  /// Half-open with a vertical hinge, held like a book.
  bool get isBook =>
      posture == FoldPosture.halfOpened && hingeAxis == Axis.vertical;

  /// Whether content should avoid crossing the fold.
  ///
  /// True for a physical hinge (dual-screen devices) and for a flexible
  /// fold that is half-open. A flexible screen lying flat is not
  /// separating, so content may span it.
  bool get isSeparating {
    final f = feature;
    if (f == null) return false;
    return f.type == DisplayFeatureType.hinge ||
        posture == FoldPosture.halfOpened;
  }

  /// The two regions of a screen of [screenSize] on either side of the fold.
  ///
  /// Returns `(left, right)` for a vertical hinge and `(top, bottom)` for a
  /// horizontal one, in global coordinates. Returns `null` when there is no
  /// fold or its direction is unknown.
  (Rect, Rect)? panes(Size screenSize) {
    final b = bounds;
    if (b == null) return null;
    return switch (hingeAxis) {
      Axis.vertical => (
        Rect.fromLTRB(0, 0, b.left, screenSize.height),
        Rect.fromLTRB(b.right, 0, screenSize.width, screenSize.height),
      ),
      Axis.horizontal => (
        Rect.fromLTRB(0, 0, screenSize.width, b.top),
        Rect.fromLTRB(0, b.bottom, screenSize.width, screenSize.height),
      ),
      null => null,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FoldInfo && other.feature == feature;

  @override
  int get hashCode => feature.hashCode;

  @override
  String toString() => hasFold
      ? 'FoldInfo(posture: ${posture.name}, axis: ${hingeAxis?.name}, '
            'separating: $isSeparating, bounds: $bounds)'
      : 'FoldInfo.none()';
}
