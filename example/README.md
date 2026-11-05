# responsive_device_type example

A showcase app for [`responsive_device_type`](https://pub.dev/packages/responsive_device_type).

- Uses `DeviceBreakpointsData.material3()` (window-width classification).
- Switches between bottom navigation (compact) and a navigation rail (expanded).
- Shows tablet sub-sizes with exhaustive `switch` patterns.
- On dual-screen devices and half-open foldables, `DualPaneLayout` shows the
  showcase and the fold details on either side of the hinge.

Run it on a phone, a tablet, a resizable desktop window, or an Android
foldable emulator:

```bash
flutter run
```
