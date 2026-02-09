import 'package:flutter/foundation.dart';

/// Defines the breakpoints for tablet size classifications.
///
/// Use named constructors for common presets or create custom breakpoints.
@immutable
final class TabletBreakpoints {
  /// Creates custom tablet breakpoints.
  const TabletBreakpoints({
    required this.smallMaxShortestSide,
    required this.mediumMaxShortestSide,
  }) : assert(
         smallMaxShortestSide < mediumMaxShortestSide,
         'smallMaxShortestSide must be less than mediumMaxShortestSide',
       );

  /// Default tablet breakpoints.
  /// Small: < 720, Medium: 720-899, Large: >= 900
  const TabletBreakpoints.defaults()
    : smallMaxShortestSide = 720,
      mediumMaxShortestSide = 900;

  /// Compact tablet breakpoints for smaller ranges.
  /// Small: < 680, Medium: 680-840, Large: >= 840
  const TabletBreakpoints.compact()
    : smallMaxShortestSide = 680,
      mediumMaxShortestSide = 840;

  /// Wide tablet breakpoints for larger ranges.
  /// Small: < 768, Medium: 768-960, Large: >= 960
  const TabletBreakpoints.wide()
    : smallMaxShortestSide = 768,
      mediumMaxShortestSide = 960;

  /// Maximum shortest side for small tablets.
  final double smallMaxShortestSide;

  /// Maximum shortest side for medium tablets.
  /// Large tablets are anything above this value.
  final double mediumMaxShortestSide;

  /// Classifies the tablet size based on the shortest side.
  TabletSize classify(double shortestSide) {
    if (shortestSide < smallMaxShortestSide) {
      return const TabletSizeSmall();
    } else if (shortestSide < mediumMaxShortestSide) {
      return const TabletSizeMedium();
    } else {
      return const TabletSizeLarge();
    }
  }

  /// Classifies the tablet size based on width only.
  ///
  /// Unlike [classify] which uses the shortest side,
  /// this method uses the provided [width] directly.
  TabletSize classifyFromWidth(double width) {
    if (width < smallMaxShortestSide) {
      return const TabletSizeSmall();
    } else if (width < mediumMaxShortestSide) {
      return const TabletSizeMedium();
    } else {
      return const TabletSizeLarge();
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabletBreakpoints &&
          other.smallMaxShortestSide == smallMaxShortestSide &&
          other.mediumMaxShortestSide == mediumMaxShortestSide;

  @override
  int get hashCode => Object.hash(smallMaxShortestSide, mediumMaxShortestSide);

  @override
  String toString() =>
      'TabletBreakpoints(small: <$smallMaxShortestSide, medium: <$mediumMaxShortestSide)';
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

/// Small tablets (< 720dp by default).
///
/// Examples: iPad Mini (744x1133)
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

/// Medium tablets (720-899dp by default).
///
/// Examples: iPad (810x1080)
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

/// Large tablets (>= 900dp by default).
///
/// Examples: iPad Pro 11" (834x1194)
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
