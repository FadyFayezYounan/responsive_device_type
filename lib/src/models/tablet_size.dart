import 'package:flutter/foundation.dart';

/// Thresholds that split `DeviceTypeTablet` into small, medium, and large.
///
/// Values are logical pixels, measured along the same dimension the active
/// `ClassificationStrategy` uses (the shortest side for `StandardStrategy`,
/// the window width for `WindowWidthStrategy`).
///
/// | Size   | Default range (`defaults()`) | Example devices (portrait, dp)          |
/// |--------|------------------------------|-----------------------------------------|
/// | small  | < 720                        | Nexus 7 (600), Pixel Fold inner (~701)  |
/// | medium | 720 – 899                    | iPad mini (744), iPad (820), iPad Pro 11" (834) |
/// | large  | >= 900                       | 10"+ Android tablets, resized windows   |
///
/// Note that almost every iPad lands in `medium` with the defaults. Use
/// [TabletBreakpoints.compact] or a custom instance if you need to split them.
@immutable
final class TabletBreakpoints {
  /// Creates custom tablet breakpoints.
  ///
  /// Both values must be positive and `smallMax < mediumMax`.
  const TabletBreakpoints({required this.smallMax, required this.mediumMax})
    : assert(smallMax > 0, 'smallMax must be positive'),
      assert(smallMax < mediumMax, 'smallMax must be less than mediumMax');

  /// Default tablet breakpoints: small `< 720`, medium `< 900`, large `>= 900`.
  const TabletBreakpoints.defaults() : smallMax = 720, mediumMax = 900;

  /// Compact tablet breakpoints: small `< 680`, medium `< 800`, large `>= 800`.
  ///
  /// Splits iPads: iPad mini (744) is medium, iPad (820) and
  /// iPad Pro 11" (834) are large.
  const TabletBreakpoints.compact() : smallMax = 680, mediumMax = 800;

  /// Wide tablet breakpoints: small `< 768`, medium `< 960`, large `>= 960`.
  const TabletBreakpoints.wide() : smallMax = 768, mediumMax = 960;

  /// Upper bound (exclusive) for [TabletSizeSmall].
  final double smallMax;

  /// Upper bound (exclusive) for [TabletSizeMedium]. Anything at or above
  /// this value is [TabletSizeLarge].
  final double mediumMax;

  /// Classifies a tablet by [extent], the dimension chosen by the strategy.
  TabletSize classify(double extent) {
    if (extent < smallMax) return const TabletSize.small();
    if (extent < mediumMax) return const TabletSize.medium();
    return const TabletSize.large();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabletBreakpoints &&
          other.smallMax == smallMax &&
          other.mediumMax == mediumMax;

  @override
  int get hashCode => Object.hash(smallMax, mediumMax);

  @override
  String toString() =>
      'TabletBreakpoints(smallMax: $smallMax, mediumMax: $mediumMax)';
}

/// Tablet size classifications.
///
/// This is a sealed class hierarchy enabling exhaustive pattern matching:
///
/// ```dart
/// final columns = switch (tabletSize) {
///   TabletSizeSmall() => 2,
///   TabletSizeMedium() => 3,
///   TabletSizeLarge() => 4,
/// };
/// ```
@immutable
sealed class TabletSize {
  const TabletSize._();

  /// Creates a small tablet size.
  const factory TabletSize.small() = TabletSizeSmall;

  /// Creates a medium tablet size.
  const factory TabletSize.medium() = TabletSizeMedium;

  /// Creates a large tablet size.
  const factory TabletSize.large() = TabletSizeLarge;

  /// Returns the name of this tablet size as a lowercase string.
  String get name;

  /// Returns `true` if this is a small tablet.
  bool get isSmall;

  /// Returns `true` if this is a medium tablet.
  bool get isMedium;

  /// Returns `true` if this is a large tablet.
  bool get isLarge;

  /// Returns a simple string representation of this tablet size.
  String toSimpleString() => name;

  /// Pattern matching method that requires handling all tablet sizes.
  ///
  /// ```dart
  /// final columns = tabletSize.when(
  ///   small: () => 2,
  ///   medium: () => 3,
  ///   large: () => 4,
  /// );
  /// ```
  T when<T>({
    required T Function() small,
    required T Function() medium,
    required T Function() large,
  });

  /// Pattern matching method with optional handlers and a fallback.
  ///
  /// ```dart
  /// final columns = tabletSize.maybeWhen(
  ///   large: () => 4,
  ///   orElse: () => 2,
  /// );
  /// ```
  T maybeWhen<T>({
    required T Function() orElse,
    T Function()? small,
    T Function()? medium,
    T Function()? large,
  });

  /// Pattern matching method that returns null if no handler matches.
  ///
  /// ```dart
  /// final columns = tabletSize.whenOrNull(
  ///   large: () => 4,
  /// );
  /// ```
  T? whenOrNull<T>({
    T Function()? small,
    T Function()? medium,
    T Function()? large,
  });

  /// Map method with access to the concrete tablet size instance.
  ///
  /// ```dart
  /// final label = tabletSize.map(
  ///   small: (s) => 'Small: ${s.name}',
  ///   medium: (m) => 'Medium: ${m.name}',
  ///   large: (l) => 'Large: ${l.name}',
  /// );
  /// ```
  T map<T>({
    required T Function(TabletSizeSmall) small,
    required T Function(TabletSizeMedium) medium,
    required T Function(TabletSizeLarge) large,
  });

  /// Map method with optional handlers and a fallback.
  ///
  /// ```dart
  /// final label = tabletSize.maybeMap(
  ///   large: (l) => 'Large tablet',
  ///   orElse: (t) => 'Other tablet',
  /// );
  /// ```
  T maybeMap<T>({
    required T Function(TabletSize) orElse,
    T Function(TabletSizeSmall)? small,
    T Function(TabletSizeMedium)? medium,
    T Function(TabletSizeLarge)? large,
  });

  /// Map method that returns null if no handler matches.
  ///
  /// ```dart
  /// final label = tabletSize.mapOrNull(
  ///   large: (l) => 'Large tablet',
  /// );
  /// ```
  T? mapOrNull<T>({
    T Function(TabletSizeSmall)? small,
    T Function(TabletSizeMedium)? medium,
    T Function(TabletSizeLarge)? large,
  });
}

/// Small tablets (`< 720` by default).
///
/// Examples: 7" Android tablets, unfolded book-style foldables.
final class TabletSizeSmall extends TabletSize {
  /// Creates a [TabletSizeSmall] instance.
  const TabletSizeSmall() : super._();

  @override
  String get name => 'small';

  @override
  bool get isSmall => true;

  @override
  bool get isMedium => false;

  @override
  bool get isLarge => false;

  @override
  T when<T>({
    required T Function() small,
    required T Function() medium,
    required T Function() large,
  }) => small();

  @override
  T maybeWhen<T>({
    required T Function() orElse,
    T Function()? small,
    T Function()? medium,
    T Function()? large,
  }) => small?.call() ?? orElse();

  @override
  T? whenOrNull<T>({
    T Function()? small,
    T Function()? medium,
    T Function()? large,
  }) => small?.call();

  @override
  T map<T>({
    required T Function(TabletSizeSmall) small,
    required T Function(TabletSizeMedium) medium,
    required T Function(TabletSizeLarge) large,
  }) => small(this);

  @override
  T maybeMap<T>({
    required T Function(TabletSize) orElse,
    T Function(TabletSizeSmall)? small,
    T Function(TabletSizeMedium)? medium,
    T Function(TabletSizeLarge)? large,
  }) => small?.call(this) ?? orElse(this);

  @override
  T? mapOrNull<T>({
    T Function(TabletSizeSmall)? small,
    T Function(TabletSizeMedium)? medium,
    T Function(TabletSizeLarge)? large,
  }) => small?.call(this);

  @override
  bool operator ==(Object other) => other is TabletSizeSmall;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'TabletSize.small';
}

/// Medium tablets (`720 – 899` by default).
///
/// Examples: iPad mini (744x1133), iPad (820x1180), iPad Pro 11" (834x1194).
final class TabletSizeMedium extends TabletSize {
  /// Creates a [TabletSizeMedium] instance.
  const TabletSizeMedium() : super._();

  @override
  String get name => 'medium';

  @override
  bool get isSmall => false;

  @override
  bool get isMedium => true;

  @override
  bool get isLarge => false;

  @override
  T when<T>({
    required T Function() small,
    required T Function() medium,
    required T Function() large,
  }) => medium();

  @override
  T maybeWhen<T>({
    required T Function() orElse,
    T Function()? small,
    T Function()? medium,
    T Function()? large,
  }) => medium?.call() ?? orElse();

  @override
  T? whenOrNull<T>({
    T Function()? small,
    T Function()? medium,
    T Function()? large,
  }) => medium?.call();

  @override
  T map<T>({
    required T Function(TabletSizeSmall) small,
    required T Function(TabletSizeMedium) medium,
    required T Function(TabletSizeLarge) large,
  }) => medium(this);

  @override
  T maybeMap<T>({
    required T Function(TabletSize) orElse,
    T Function(TabletSizeSmall)? small,
    T Function(TabletSizeMedium)? medium,
    T Function(TabletSizeLarge)? large,
  }) => medium?.call(this) ?? orElse(this);

  @override
  T? mapOrNull<T>({
    T Function(TabletSizeSmall)? small,
    T Function(TabletSizeMedium)? medium,
    T Function(TabletSizeLarge)? large,
  }) => medium?.call(this);

  @override
  bool operator ==(Object other) => other is TabletSizeMedium;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'TabletSize.medium';
}

/// Large tablets (`>= 900` by default).
///
/// Examples: large Android tablets and desktop windows in the tablet range.
final class TabletSizeLarge extends TabletSize {
  /// Creates a [TabletSizeLarge] instance.
  const TabletSizeLarge() : super._();

  @override
  String get name => 'large';

  @override
  bool get isSmall => false;

  @override
  bool get isMedium => false;

  @override
  bool get isLarge => true;

  @override
  T when<T>({
    required T Function() small,
    required T Function() medium,
    required T Function() large,
  }) => large();

  @override
  T maybeWhen<T>({
    required T Function() orElse,
    T Function()? small,
    T Function()? medium,
    T Function()? large,
  }) => large?.call() ?? orElse();

  @override
  T? whenOrNull<T>({
    T Function()? small,
    T Function()? medium,
    T Function()? large,
  }) => large?.call();

  @override
  T map<T>({
    required T Function(TabletSizeSmall) small,
    required T Function(TabletSizeMedium) medium,
    required T Function(TabletSizeLarge) large,
  }) => large(this);

  @override
  T maybeMap<T>({
    required T Function(TabletSize) orElse,
    T Function(TabletSizeSmall)? small,
    T Function(TabletSizeMedium)? medium,
    T Function(TabletSizeLarge)? large,
  }) => large?.call(this) ?? orElse(this);

  @override
  T? mapOrNull<T>({
    T Function(TabletSizeSmall)? small,
    T Function(TabletSizeMedium)? medium,
    T Function(TabletSizeLarge)? large,
  }) => large?.call(this);

  @override
  bool operator ==(Object other) => other is TabletSizeLarge;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'TabletSize.large';
}
