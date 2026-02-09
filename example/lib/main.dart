import 'package:flutter/material.dart';
import 'package:responsive_device_type/responsive_device_type.dart';

void main() {
  runApp(const ResponsiveDeviceTypeExampleApp());
}

class ResponsiveDeviceTypeExampleApp extends StatelessWidget {
  const ResponsiveDeviceTypeExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DeviceBreakpoints(
      breakpoints: const DeviceBreakpointsData.material3(),
      child: MaterialApp(
        title: 'Responsive Device Type Demo',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),
        home: const ResponsiveShowcasePage(),
      ),
    );
  }
}

class ResponsiveShowcasePage extends StatelessWidget {
  const ResponsiveShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DeviceTypeBuilder(
      builder: (context, deviceType) {
        final isCompact = deviceType.isCompact;

        return Scaffold(
          appBar: AppBar(title: const Text('Responsive Device Type')),
          drawer: isCompact ? const _AppDrawer() : null,
          bottomNavigationBar: isCompact ? const _BottomBar() : null,
          body: Row(
            children: [
              if (deviceType.isExpanded) const _NavigationRail(),
              Expanded(child: _ShowcaseBody(deviceType: deviceType)),
            ],
          ),
        );
      },
    );
  }
}

class _ShowcaseBody extends StatelessWidget {
  const _ShowcaseBody({required this.deviceType});

  final DeviceType deviceType;

  @override
  Widget build(BuildContext context) {
    final padding = deviceType.isCompact ? 16.0 : 24.0;
    final breakpoints = DeviceBreakpoints.of(context);
    final size = MediaQuery.sizeOf(context);
    final columns = switch (deviceType) {
      DeviceTypeWatch() => 1,
      DeviceTypeMobile() => 2,
      DeviceTypeTablet(size: TabletSizeSmall()) => 2,
      DeviceTypeTablet(size: TabletSizeMedium()) => 3,
      DeviceTypeTablet(size: TabletSizeLarge()) => 4,
      DeviceTypeTablet() => 3,
      DeviceTypeLargeScreen() => 4,
    };

    return ListView(
      padding: EdgeInsets.all(padding),
      children: [
        _HeroCard(deviceType: deviceType, size: size, breakpoints: breakpoints),
        const SizedBox(height: 20),
        const _SectionTitle(title: 'Adaptive grid'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: columns,
          childAspectRatio: deviceType.isCompact ? 1.05 : 1.35,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: _featureCards,
        ),
        const SizedBox(height: 24),
        const _SectionTitle(title: 'Pattern matching'),
        const SizedBox(height: 12),
        _PatternCard(deviceType: deviceType),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.deviceType,
    required this.size,
    required this.breakpoints,
  });

  final DeviceType deviceType;
  final Size size;
  final DeviceBreakpointsData breakpoints;

  @override
  Widget build(BuildContext context) {
    final typeFromContext = DeviceBreakpoints.deviceTypeOf(context);
    final tabletSizeInfo = deviceType is DeviceTypeTablet
        ? (deviceType as DeviceTypeTablet).size?.name ?? 'unspecified'
        : 'N/A';

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current device: ${deviceType.toSimpleString()}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'MediaQuery: ${size.width.toStringAsFixed(0)} x '
              '${size.height.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  label: 'from builder',
                  value: deviceType.toSimpleString(),
                ),
                _InfoChip(
                  label: 'from context',
                  value: typeFromContext.toSimpleString(),
                ),
                if (deviceType.isTablet)
                  _InfoChip(label: 'tablet size', value: tabletSizeInfo),
                _InfoChip(
                  label: 'breakpoints',
                  value:
                      '<${breakpoints.watchMaxShortestSide.toInt()} '
                      '/ <${breakpoints.mobileMaxShortestSide.toInt()} '
                      '/ <${breakpoints.tabletMaxShortestSide.toInt()}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PatternCard extends StatelessWidget {
  const _PatternCard({required this.deviceType});

  final DeviceType deviceType;

  @override
  Widget build(BuildContext context) {
    final message = switch (deviceType) {
      DeviceTypeWatch() =>
        'Watch layout: keep copy short and tap targets large.',
      DeviceTypeMobile() => 'Mobile layout: single column, bottom navigation.',
      DeviceTypeTablet(size: TabletSizeSmall()) =>
        'Small tablet layout: 2 columns, suitable for compact tablet displays.',
      DeviceTypeTablet(size: TabletSizeMedium()) =>
        'Medium tablet layout: 3 columns, balanced for standard tablets.',
      DeviceTypeTablet(size: TabletSizeLarge()) =>
        'Large tablet layout: 4 columns, optimized for iPad Pro-sized devices.',
      DeviceTypeTablet() => 'Tablet layout: introduce a second column or rail.',
      DeviceTypeLargeScreen() =>
        'Large screen layout: show persistent navigation and density.',
    };

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationRail extends StatelessWidget {
  const _NavigationRail();

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: 0,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Overview'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view),
          label: Text('Grid'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Overview',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view),
          label: 'Grid',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          DrawerHeader(child: Text('Navigation')),
          ListTile(
            leading: Icon(Icons.dashboard_outlined),
            title: Text('Overview'),
          ),
          ListTile(
            leading: Icon(Icons.grid_view_outlined),
            title: Text('Grid'),
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text('Settings'),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

const _featureCards = [
  _FeatureCard(
    title: 'DeviceTypeBuilder',
    body: 'Use builder callbacks to switch layouts by device type.',
  ),
  _FeatureCard(
    title: 'Breakpoints scope',
    body: 'Provide app-wide thresholds with DeviceBreakpoints.',
  ),
  _FeatureCard(
    title: 'Pattern matching',
    body: 'Exhaustive switch expressions keep layouts explicit.',
  ),
  _FeatureCard(
    title: 'Compact vs expanded',
    body: 'Use isCompact / isExpanded for coarse layout decisions.',
  ),
  _FeatureCard(
    title: 'Orientation-proof',
    body: 'Uses shortestSide so rotations do not flip categories.',
  ),
  _FeatureCard(
    title: 'Zero deps',
    body: 'Package relies only on the Flutter SDK.',
  ),
];
