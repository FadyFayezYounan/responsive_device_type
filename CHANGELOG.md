# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.0.0 - 2026-11-05

Initial release.

### Classification

- Sealed `DeviceType` hierarchy: `DeviceTypeWatch`, `DeviceTypeMobile`,
  `DeviceTypeTablet`, `DeviceTypeLargeScreen`.
- Tablets carry a sealed `TabletSize` (small, medium, large), configured with
  `TabletBreakpoints` (`defaults()`, `compact()`, `wide()`, or custom).
- `DeviceBreakpointsData` with `watchMax`, `mobileMax`, `tabletMax`,
  `tabletBreakpoints`, and `strategy`, plus `defaults()` and `material3()`
  presets.
- Strategies: `StandardStrategy` (shortest side, default),
  `WindowWidthStrategy` (width, used by `material3()`), and
  `StrictTabletStrategy` (wide landscape windows become large screens).
  Custom strategies extend `ClassificationStrategy` and can reuse
  `classifyExtent`.
- `DeviceType.isAtLeast` / `isAtMost` comparisons and the mobile-first
  `DeviceType.select`.
- `DeviceType.fromSize` and `DeviceType.fromWidth` for use without a
  `BuildContext`.
- `when` / `maybeWhen` / `whenOrNull` / `map` / `maybeMap` / `mapOrNull` on
  `DeviceType` and `TabletSize`.

### Widgets and context

- `DeviceBreakpoints` scope with `of`, `maybeOf`, `deviceTypeOf`, and
  `maybeDeviceTypeOf`.
- `BuildContext` extension `DeviceTypeContext`: `deviceType`,
  `deviceBreakpoints`, `foldInfo`, `isWatch`, `isMobile`, `isTablet`,
  `isLargeScreen`, `isCompact`, `isExpanded`, and `responsive(...)`.
- `DeviceTypeBuilder`, `ResponsiveLayout`, `ResponsiveValue`,
  `DeviceTypeSwitcher`, and `DeviceTypeVisibility`. Only `mobile` is
  required; missing entries fall back mobile-first.

### Foldables

- `FoldInfo` reads the fold or hinge from `MediaQuery.displayFeaturesOf`:
  `posture`, `hingeAxis`, `isTabletop`, `isBook`, `isSeparating`, `bounds`,
  and `panes`.
- `DualPaneLayout` places two widgets around a separating hinge, respects
  text direction, and gives each pane its own `MediaQuery`.
