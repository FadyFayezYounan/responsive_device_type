import 'package:flutter/widgets.dart';

import 'package:responsive_device_type/src/core/scope.dart';
import 'package:responsive_device_type/src/models/device_type.dart';

/// Resolves a value for the current [DeviceType] and passes it to [builder].
///
/// Only [mobile] is required. Missing values fall back mobile-first, see
/// [DeviceType.select].
///
/// ```dart
/// ResponsiveValue<double>(
///   mobile: 12,
///   tablet: 16,
///   largeScreen: 24,
///   builder: (context, padding) => Padding(
///     padding: EdgeInsets.all(padding),
///     child: const Text('Hello'),
///   ),
/// )
/// ```
///
/// Inside a `build` method, `context.responsive(...)` does the same without
/// a widget.
class ResponsiveValue<T> extends StatelessWidget {
  /// Creates a [ResponsiveValue].
  const ResponsiveValue({
    required this.mobile,
    required this.builder,
    this.watch,
    this.tablet,
    this.largeScreen,
    super.key,
  });

  /// Value for watch devices. Falls back to [mobile].
  final T? watch;

  /// Value for mobile devices, and the final fallback.
  final T mobile;

  /// Value for tablet devices. Falls back to [mobile].
  final T? tablet;

  /// Value for large screens. Falls back to [tablet], then [mobile].
  final T? largeScreen;

  /// Builds a widget with the resolved value.
  final Widget Function(BuildContext context, T value) builder;

  @override
  Widget build(BuildContext context) {
    final value = DeviceBreakpoints.deviceTypeOf(context).select(
      mobile: mobile,
      watch: watch,
      tablet: tablet,
      largeScreen: largeScreen,
    );
    return builder(context, value);
  }
}
