import 'package:flutter/widgets.dart';

import 'package:responsive_device_type/src/core/scope.dart';
import 'package:responsive_device_type/src/models/device_type.dart';

/// Resolves a per-device value and passes it to a builder.
///
/// Example:
/// ```dart
/// ResponsiveValue<double>(
///   watch: 8,
///   mobile: 12,
///   tablet: 16,
///   largeScreen: 24,
///   builder: (context, value) => Padding(
///     padding: EdgeInsets.all(value),
///     child: const Text('Hello'),
///   ),
/// )
/// ```
class ResponsiveValue<T> extends StatelessWidget {
  /// Creates a [ResponsiveValue].
  const ResponsiveValue({
    required this.watch,
    required this.mobile,
    required this.tablet,
    required this.largeScreen,
    required this.builder,
    super.key,
  });

  /// Value for watch devices.
  final T watch;

  /// Value for mobile devices.
  final T mobile;

  /// Value for tablet devices.
  final T tablet;

  /// Value for large-screen devices.
  final T largeScreen;

  /// Builds a widget with the resolved value.
  final Widget Function(BuildContext context, T value) builder;

  @override
  Widget build(BuildContext context) {
    final type = DeviceBreakpoints.deviceTypeOf(context);
    final value = switch (type) {
      DeviceTypeWatch() => watch,
      DeviceTypeMobile() => mobile,
      DeviceTypeTablet() => tablet,
      DeviceTypeLargeScreen() => largeScreen,
    };
    return builder(context, value);
  }
}
