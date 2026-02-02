# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-01

### Added

- **Device Type Classification**: Sealed class hierarchy (`DeviceType`) with four device categories:
  - `DeviceTypeWatch`: For smartwatches and very small screens (< 300)
  - `DeviceTypeMobile`: For phones and handheld devices (300 - 599)
  - `DeviceTypeTablet`: For tablets and medium screens (600 - 1023)
  - `DeviceTypeLargeScreen`: For desktops, laptops, and TVs (>= 1024)

- **DeviceBreakpoints**: Configurable threshold values for device classification
  - `DeviceBreakpoints()`: Default constructor with sensible defaults
  - `DeviceBreakpoints.defaults()`: Explicit default breakpoints
  - `DeviceBreakpoints.material3()`: Material Design 3 window size classes
  - `copyWith()` for easy customization

- **Classification Strategies**: Pluggable strategies for different use cases
  - `StandardStrategy`: Simple shortestSide-based classification
  - `StrictTabletStrategy`: Enhanced tablet detection for web/desktop apps

- **DeviceBreakpointsScope**: InheritedWidget for per-subtree breakpoint customization
  - `of(context)`: Get breakpoints or throw
  - `maybeOf(context)`: Get breakpoints or null

- **DeviceTypeResolver**: Static methods for device type resolution
  - `of(context)`: Resolve from BuildContext
  - `maybeOf(context)`: Safe resolution with null
  - `resolve(mediaQuery, breakpoints)`: Explicit resolution
  - `fromSize(size, breakpoints)`: Resolution from Size

- **DeviceTypeX Extension**: Convenient BuildContext extension
  - `context.deviceType`: Get current device type
  - `context.deviceTypeOrNull`: Safe device type access
  - Boolean properties: `isWatch`, `isMobile`, `isTablet`, `isLargeScreen`
  - Category properties: `isCompact`, `isExpanded`

- **Builder Widgets**: Reactive widgets for device-aware UIs
  - `DeviceTypeBuilder`: Builds based on DeviceType
  - `DeviceTypeBuilderWithData`: Provides both DeviceType and MediaQueryData

- **Factory Constructors** on DeviceType:
  - `DeviceType.fromSize(size)`: Create from Size
  - `DeviceType.fromMediaQuery(mediaQuery)`: Create from MediaQueryData

### Notes

- Zero external dependencies (Flutter SDK only)
- Full test coverage
- Comprehensive dartdocs on all public APIs
- Supports all Flutter platforms (iOS, Android, Web, macOS, Windows, Linux)
