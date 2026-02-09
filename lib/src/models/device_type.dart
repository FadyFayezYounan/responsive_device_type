import 'dart:ui' show Size;

import 'package:flutter/foundation.dart' show immutable;

import 'package:responsive_device_type/src/models/breakpoints.dart';
import 'package:responsive_device_type/src/models/tablet_size.dart';

/// Represents the classification of a device based on screen dimensions.
///
/// The device types are ordered from smallest to largest:
/// - [DeviceTypeWatch]: Very small screens like smartwatches
/// - [DeviceTypeMobile]: Phones and small handheld devices
/// - [DeviceTypeTablet]: Tablets and medium-sized screens
/// - [DeviceTypeLargeScreen]: Desktops, laptops, and large displays
///
/// Classification is based on the `shortestSide` of the screen, which provides
/// consistent results regardless of device orientation.
///
/// ## Pattern Matching
///
/// This is a sealed class hierarchy enabling exhaustive pattern matching:
///
/// ```dart
/// final layout = switch (deviceType) {
///   DeviceTypeWatch() => const WatchLayout(),
///   DeviceTypeMobile() => const MobileLayout(),
///   DeviceTypeTablet() => const TabletLayout(),
///   DeviceTypeLargeScreen() => const DesktopLayout(),
/// };
/// ```
///
/// ## Factory Constructors
///
/// Create a [DeviceType] from screen dimensions:
///
/// ```dart
/// // From Size
/// final type = DeviceType.fromSize(Size(393, 852));
///
/// // From MediaQueryData
/// final type = DeviceType.fromMediaQuery(MediaQuery.of(context));
/// ```
///
/// ## Convenience Getters
///
/// Check device categories:
///
/// ```dart
/// if (deviceType.isCompact) {
///   // Watch or mobile
/// }
/// if (deviceType.isExpanded) {
///   // Tablet or large screen
/// }
/// ```
///
/// See also:
///
///  * [DeviceBreakpointsData], which defines the threshold values for classification.
///  * [DeviceBreakpointsScope], which provides breakpoints to a widget subtree.
@immutable
sealed class DeviceType {
  const DeviceType._();

  // Factory constructors for each device type
  const factory DeviceType.watch() = DeviceTypeWatch;
  const factory DeviceType.mobile() = DeviceTypeMobile;
  const factory DeviceType.tablet({required TabletSize size}) = DeviceTypeTablet;
  const factory DeviceType.largeScreen() = DeviceTypeLargeScreen;

  /// Creates a [DeviceType] from the given screen [size].
  ///
  /// Uses the provided [breakpoints] for classification thresholds.
  /// If not specified, defaults to [DeviceBreakpoints.defaults].
  ///
  /// ```dart
  /// final type = DeviceType.fromSize(
  ///   Size(393, 852),
  ///   breakpoints: DeviceBreakpoints(mobileMaxShortestSide: 640),
  /// );
  /// ```
  factory DeviceType.fromSize(
    Size size, {
    DeviceBreakpointsData breakpoints = const DeviceBreakpointsData(),
  }) {
    return breakpoints.classify(size);
  }

  /// Creates a [DeviceType] from the given screen [width].
  ///
  /// Unlike [fromSize] which uses the shortest side,
  /// this method uses the provided [width] directly.
  ///
  /// Uses the provided [breakpoints] for classification thresholds.
  /// If not specified, defaults to [DeviceBreakpoints.defaults].
  ///
  /// ```dart
  /// final type = DeviceType.fromWidth(393);
  /// ```
  factory DeviceType.fromWidth(
    double width, {
    DeviceBreakpointsData breakpoints = const DeviceBreakpointsData(),
  }) {
    return breakpoints.classifyFromWidth(width);
  }

  /// Returns `true` if this device type is [DeviceTypeWatch].
  bool get isWatch;

  /// Returns `true` if this device type is [DeviceTypeMobile].
  bool get isMobile;

  /// Returns `true` if this device type is [DeviceTypeTablet].
  bool get isTablet;

  /// Returns `true` if this device type is [DeviceTypeLargeScreen].
  bool get isLargeScreen;

  /// Returns `true` if this device is compact (watch or mobile).
  ///
  /// Compact devices typically use single-column layouts, bottom navigation,
  /// and full-screen dialogs.
  bool get isCompact => isWatch || isMobile;

  /// Returns `true` if this device is expanded (tablet or large screen).
  ///
  /// Expanded devices typically use multi-column layouts, navigation rails
  /// or drawers, and can display master-detail views.
  bool get isExpanded => isTablet || isLargeScreen;

  /// Returns `true` if this device is handheld (watch or mobile).
  bool get isHandheld => isWatch || isMobile;

  /// Returns `true` if this device has limited space (watch or mobile).
  bool get hasLimitedSpace => isWatch || isMobile;

  /// Returns `true` if this device typically supports hover interactions.
  bool get supportsHover => isLargeScreen;

  /// Returns `true` if this device prefers touch input.
  bool get prefersTouchInput => !isLargeScreen;

  /// Returns the name of this device type as a lowercase string.
  ///
  /// Possible values: `'watch'`, `'mobile'`, `'tablet'`, `'largeScreen'`
  String get name;

  /// Returns a simple string representation of this device type.
  ///
  /// This returns just the device type name without the class prefix.
  /// For example: `'watch'`, `'mobile'`, `'tablet'`, `'largeScreen'`
  String toSimpleString() => name;

  /// Pattern matching method that requires handling all device types.
  ///
  /// The [tablet] callback receives the [TabletSize?] for further
  /// tablet size classification.
  ///
  /// ```dart
  /// final layout = deviceType.when(
  ///   watch: () => WatchLayout(),
  ///   mobile: () => MobileLayout(),
  ///   tablet: (size) => TabletLayout(size: size),
  ///   largeScreen: () => DesktopLayout(),
  /// );
  /// ```
  T when<T>({
    required T Function() watch,
    required T Function() mobile,
    required T Function(TabletSize? size) tablet,
    required T Function() largeScreen,
  });

  /// Pattern matching method with optional handlers and a fallback.
  ///
  /// The [tablet] callback receives the [TabletSize?] for further
  /// tablet size classification.
  ///
  /// ```dart
  /// final layout = deviceType.maybeWhen(
  ///   mobile: () => MobileLayout(),
  ///   tablet: (size) => TabletLayout(size: size),
  ///   orElse: () => DefaultLayout(),
  /// );
  /// ```
  T maybeWhen<T>({
    required T Function() orElse,
    T Function()? watch,
    T Function()? mobile,
    T Function(TabletSize? size)? tablet,
    T Function()? largeScreen,
  });

  /// Pattern matching method that returns null if no handler matches.
  ///
  /// The [tablet] callback receives the [TabletSize?] for further
  /// tablet size classification.
  ///
  /// ```dart
  /// final layout = deviceType.whenOrNull(
  ///   mobile: () => MobileLayout(),
  ///   tablet: (size) => TabletLayout(size: size),
  /// );
  /// ```
  T? whenOrNull<T>({
    T Function()? watch,
    T Function()? mobile,
    T Function(TabletSize? size)? tablet,
    T Function()? largeScreen,
  });

  /// Map method with access to the concrete device type instance.
  ///
  /// ```dart
  /// final layout = deviceType.map(
  ///   watch: (watch) => WatchLayout(),
  ///   mobile: (mobile) => MobileLayout(),
  ///   tablet: (tablet) => TabletLayout(),
  ///   largeScreen: (largeScreen) => DesktopLayout(),
  /// );
  /// ```
  T map<T>({
    required T Function(DeviceTypeWatch) watch,
    required T Function(DeviceTypeMobile) mobile,
    required T Function(DeviceTypeTablet) tablet,
    required T Function(DeviceTypeLargeScreen) largeScreen,
  });

  /// Map method with optional handlers and a fallback.
  ///
  /// ```dart
  /// final layout = deviceType.maybeMap(
  ///   mobile: (mobile) => MobileLayout(),
  ///   orElse: (device) => DefaultLayout(),
  /// );
  /// ```
  T maybeMap<T>({
    required T Function(DeviceType) orElse,
    T Function(DeviceTypeWatch)? watch,
    T Function(DeviceTypeMobile)? mobile,
    T Function(DeviceTypeTablet)? tablet,
    T Function(DeviceTypeLargeScreen)? largeScreen,
  });

  /// Map method that returns null if no handler matches.
  ///
  /// ```dart
  /// final layout = deviceType.mapOrNull(
  ///   mobile: (mobile) => MobileLayout(),
  ///   tablet: (tablet) => TabletLayout(),
  /// );
  /// ```
  T? mapOrNull<T>({
    T Function(DeviceTypeWatch)? watch,
    T Function(DeviceTypeMobile)? mobile,
    T Function(DeviceTypeTablet)? tablet,
    T Function(DeviceTypeLargeScreen)? largeScreen,
  });
}

/// Very small screens, typically smartwatches.
///
/// Default threshold: `shortestSide < 300`
///
/// Examples of watch devices:
/// * Apple Watch: 162x197 (38mm), 184x224 (44mm)
/// * Galaxy Watch: 360x360
final class DeviceTypeWatch extends DeviceType {
  /// Creates a [DeviceTypeWatch] instance.
  const DeviceTypeWatch() : super._();

  @override
  String get name => 'watch';

  @override
  bool get isWatch => true;

  @override
  bool get isMobile => false;

  @override
  bool get isTablet => false;

  @override
  bool get isLargeScreen => false;

  @override
  T when<T>({
    required T Function() watch,
    required T Function() mobile,
    required T Function(TabletSize? size) tablet,
    required T Function() largeScreen,
  }) => watch();

  @override
  T maybeWhen<T>({
    required T Function() orElse,
    T Function()? watch,
    T Function()? mobile,
    T Function(TabletSize? size)? tablet,
    T Function()? largeScreen,
  }) => watch?.call() ?? orElse();

  @override
  T? whenOrNull<T>({
    T Function()? watch,
    T Function()? mobile,
    T Function(TabletSize? size)? tablet,
    T Function()? largeScreen,
  }) => watch?.call();

  @override
  T map<T>({
    required T Function(DeviceTypeWatch) watch,
    required T Function(DeviceTypeMobile) mobile,
    required T Function(DeviceTypeTablet) tablet,
    required T Function(DeviceTypeLargeScreen) largeScreen,
  }) => watch(this);

  @override
  T maybeMap<T>({
    required T Function(DeviceType) orElse,
    T Function(DeviceTypeWatch)? watch,
    T Function(DeviceTypeMobile)? mobile,
    T Function(DeviceTypeTablet)? tablet,
    T Function(DeviceTypeLargeScreen)? largeScreen,
  }) => watch?.call(this) ?? orElse(this);

  @override
  T? mapOrNull<T>({
    T Function(DeviceTypeWatch)? watch,
    T Function(DeviceTypeMobile)? mobile,
    T Function(DeviceTypeTablet)? tablet,
    T Function(DeviceTypeLargeScreen)? largeScreen,
  }) => watch?.call(this);

  @override
  bool operator ==(Object other) => other is DeviceTypeWatch;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'DeviceType.watch';
}

/// Phones and small handheld devices.
///
/// Default threshold: `300 <= shortestSide < 600`
///
/// Examples of mobile devices:
/// * iPhone 14 Pro: 393x852
/// * Pixel 7: 412x915
/// * Galaxy S23: 360x780
final class DeviceTypeMobile extends DeviceType {
  /// Creates a [DeviceTypeMobile] instance.
  const DeviceTypeMobile() : super._();

  @override
  String get name => 'mobile';

  @override
  bool get isWatch => false;

  @override
  bool get isMobile => true;

  @override
  bool get isTablet => false;

  @override
  bool get isLargeScreen => false;

  @override
  T when<T>({
    required T Function() watch,
    required T Function() mobile,
    required T Function(TabletSize? size) tablet,
    required T Function() largeScreen,
  }) => mobile();

  @override
  T maybeWhen<T>({
    required T Function() orElse,
    T Function()? watch,
    T Function()? mobile,
    T Function(TabletSize? size)? tablet,
    T Function()? largeScreen,
  }) => mobile?.call() ?? orElse();

  @override
  T? whenOrNull<T>({
    T Function()? watch,
    T Function()? mobile,
    T Function(TabletSize? size)? tablet,
    T Function()? largeScreen,
  }) => mobile?.call();

  @override
  T map<T>({
    required T Function(DeviceTypeWatch) watch,
    required T Function(DeviceTypeMobile) mobile,
    required T Function(DeviceTypeTablet) tablet,
    required T Function(DeviceTypeLargeScreen) largeScreen,
  }) => mobile(this);

  @override
  T maybeMap<T>({
    required T Function(DeviceType) orElse,
    T Function(DeviceTypeWatch)? watch,
    T Function(DeviceTypeMobile)? mobile,
    T Function(DeviceTypeTablet)? tablet,
    T Function(DeviceTypeLargeScreen)? largeScreen,
  }) => mobile?.call(this) ?? orElse(this);

  @override
  T? mapOrNull<T>({
    T Function(DeviceTypeWatch)? watch,
    T Function(DeviceTypeMobile)? mobile,
    T Function(DeviceTypeTablet)? tablet,
    T Function(DeviceTypeLargeScreen)? largeScreen,
  }) => mobile?.call(this);

  @override
  bool operator ==(Object other) => other is DeviceTypeMobile;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'DeviceType.mobile';
}

/// Tablets and medium-sized screens.
///
/// Default threshold: `600 <= shortestSide < 1024`
///
/// Tablet sizes:
/// * Small: < 720 (e.g., iPad Mini: 744x1133)
/// * Medium: 720-899 (e.g., iPad: 810x1080)
/// * Large: >= 900 (e.g., iPad Pro 11": 834x1194)
///
/// Examples of tablet devices:
/// * iPad Pro 11": 834x1194
/// * iPad Mini: 744x1133
/// * Galaxy Tab S8: 753x1205
final class DeviceTypeTablet extends DeviceType {
  /// Creates a [DeviceTypeTablet] instance with optional [size] classification.
  const DeviceTypeTablet({this.size}) : super._();

  /// The size classification of this tablet.
  ///
  /// Can be [TabletSize.small], [TabletSize.medium], or [TabletSize.large].
  final TabletSize? size;

  /// Returns `true` if this is a small tablet.
  bool get isSmallTablet => size is TabletSizeSmall;

  /// Returns `true` if this is a medium tablet.
  bool get isMediumTablet => size is TabletSizeMedium;

  /// Returns `true` if this is a large tablet.
  bool get isLargeTablet => size is TabletSizeLarge;

  @override
  String get name => 'tablet';

  @override
  bool get isWatch => false;

  @override
  bool get isMobile => false;

  @override
  bool get isTablet => true;

  @override
  bool get isLargeScreen => false;

  @override
  T when<T>({
    required T Function() watch,
    required T Function() mobile,
    required T Function(TabletSize? size) tablet,
    required T Function() largeScreen,
  }) => tablet(size);

  @override
  T maybeWhen<T>({
    required T Function() orElse,
    T Function()? watch,
    T Function()? mobile,
    T Function(TabletSize? size)? tablet,
    T Function()? largeScreen,
  }) => tablet?.call(size) ?? orElse();

  @override
  T? whenOrNull<T>({
    T Function()? watch,
    T Function()? mobile,
    T Function(TabletSize? size)? tablet,
    T Function()? largeScreen,
  }) => tablet?.call(size);

  @override
  T map<T>({
    required T Function(DeviceTypeWatch) watch,
    required T Function(DeviceTypeMobile) mobile,
    required T Function(DeviceTypeTablet) tablet,
    required T Function(DeviceTypeLargeScreen) largeScreen,
  }) => tablet(this);

  @override
  T maybeMap<T>({
    required T Function(DeviceType) orElse,
    T Function(DeviceTypeWatch)? watch,
    T Function(DeviceTypeMobile)? mobile,
    T Function(DeviceTypeTablet)? tablet,
    T Function(DeviceTypeLargeScreen)? largeScreen,
  }) => tablet?.call(this) ?? orElse(this);

  @override
  T? mapOrNull<T>({
    T Function(DeviceTypeWatch)? watch,
    T Function(DeviceTypeMobile)? mobile,
    T Function(DeviceTypeTablet)? tablet,
    T Function(DeviceTypeLargeScreen)? largeScreen,
  }) => tablet?.call(this);

  @override
  bool operator ==(Object other) =>
      other is DeviceTypeTablet && other.size == size;

  @override
  int get hashCode => Object.hash(name, size);

  @override
  String toString() =>
      size != null ? 'DeviceType.tablet(${size!.name})' : 'DeviceType.tablet';
}

/// Desktops, laptops, TVs, and other large displays.
///
/// Default threshold: `shortestSide >= 1024`
///
/// Examples of large screen devices:
/// * MacBook Pro 14": 1512x982 (scaled)
/// * Desktop 1080p: 1920x1080
/// * 4K Display: 3840x2160
final class DeviceTypeLargeScreen extends DeviceType {
  /// Creates a [DeviceTypeLargeScreen] instance.
  const DeviceTypeLargeScreen() : super._();

  @override
  String get name => 'largeScreen';

  @override
  bool get isWatch => false;

  @override
  bool get isMobile => false;

  @override
  bool get isTablet => false;

  @override
  bool get isLargeScreen => true;

  @override
  T when<T>({
    required T Function() watch,
    required T Function() mobile,
    required T Function(TabletSize? size) tablet,
    required T Function() largeScreen,
  }) => largeScreen();

  @override
  T maybeWhen<T>({
    required T Function() orElse,
    T Function()? watch,
    T Function()? mobile,
    T Function(TabletSize? size)? tablet,
    T Function()? largeScreen,
  }) => largeScreen?.call() ?? orElse();

  @override
  T? whenOrNull<T>({
    T Function()? watch,
    T Function()? mobile,
    T Function(TabletSize? size)? tablet,
    T Function()? largeScreen,
  }) => largeScreen?.call();

  @override
  T map<T>({
    required T Function(DeviceTypeWatch) watch,
    required T Function(DeviceTypeMobile) mobile,
    required T Function(DeviceTypeTablet) tablet,
    required T Function(DeviceTypeLargeScreen) largeScreen,
  }) => largeScreen(this);

  @override
  T maybeMap<T>({
    required T Function(DeviceType) orElse,
    T Function(DeviceTypeWatch)? watch,
    T Function(DeviceTypeMobile)? mobile,
    T Function(DeviceTypeTablet)? tablet,
    T Function(DeviceTypeLargeScreen)? largeScreen,
  }) => largeScreen?.call(this) ?? orElse(this);

  @override
  T? mapOrNull<T>({
    T Function(DeviceTypeWatch)? watch,
    T Function(DeviceTypeMobile)? mobile,
    T Function(DeviceTypeTablet)? tablet,
    T Function(DeviceTypeLargeScreen)? largeScreen,
  }) => largeScreen?.call(this);

  @override
  bool operator ==(Object other) => other is DeviceTypeLargeScreen;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'DeviceType.largeScreen';
}
